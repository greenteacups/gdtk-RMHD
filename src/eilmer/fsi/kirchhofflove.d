module fsi.kirchhofflove;

import std.math;
import std.conv;
import std.algorithm;
import std.stdio;
import core.time;
import std.format;
import std.array;
import std.range;
import std.file;

import nm.number;
import nm.bbla;
import nm.smla;
import fsi;
import gzip;
import geom;

class KirchhoffLovePlate : FEMModel {
public:

    this(string jobName, int id) { super(jobName, id); }

    // Use snake case for formatting this function since it appears in the main code
    override void model_setup() {

        // Set some constants used in the master initialiser to allocate the correct amount 
        // of memory to the vectors/matrices- 2 DoFs per node
        nNodes = (myConfig.Nx + 1) * (myConfig.Nz + 1);
        nDoF = nNodes * 3;
        nQuadPoints = myConfig.Nx * myConfig.Nz * 4;

        super.model_setup();
    }

    override void GenerateMassStiffnessMatrices() {
        // Assign the constants bsaed on the structure geometry
        double a = myConfig.length / (2 * myConfig.Nx);
        double b = myConfig.width / (2 * myConfig.Nz);

        // Build the local mass and stiffness matrices- these are constant in both time and across elements,
        // because our elements are of uniform size.
        Matrix!double KL = LocalStiffnessMatrix(a, b, myConfig.poissonsRatio);
        KL.scale(myConfig.youngsModulus * pow(myConfig.thickness, 3) * a * b / (12 * (1 - pow(myConfig.poissonsRatio, 2))));
        Matrix!double ML = LocalMassMatrix(a, b);
        ML.scale(myConfig.density * myConfig.thickness * a * b);

        // Assign our indexers
        size_t globalNodeIndx, globalNodeIndxInner, globalRowIndx, globalColIndx, localRowIndx, localColIndx;

        // First, we iterate over all the elements
        foreach (k; 0 .. myConfig.Nz) {
            foreach (i; 0 .. myConfig.Nx) {
                // Then, we iterate over each node and DoF in the element to build the equation corresponding to that DoF
                foreach (node; 0 .. 4) {
                    globalNodeIndx = LocalNodeToGlobalNode(node, i, k);
                    foreach (DoF; 0 .. 3) {
                        localRowIndx = node * 3 + DoF;
                        globalRowIndx = globalNodeIndx * 3 + DoF;
                        // Finally, we do an inner iteration across the DoFs to compute the contributions from each DoF
                        // to the outer DoF's equation.
                        foreach (n_node; 0 .. 4) {
                            globalNodeIndxInner = LocalNodeToGlobalNode(n_node, i, k);
                            foreach (D_DoF; 0 .. 3) {
                                localColIndx = n_node * 3 + D_DoF;
                                globalColIndx = globalNodeIndxInner * 3 + D_DoF;
                                M[globalRowIndx, globalColIndx] += ML[localRowIndx, localColIndx];
                                K[globalRowIndx, globalColIndx] += KL[localRowIndx, localColIndx];
                            } // end foreach D_DoF
                        } // end foreach n_node
                    } // end foreach DoF
                } // end foreach node
            } // end foreach i
        } // end foreach k

        // Apply the boundary conditions, diagonal ones for fixed nodes.
        foreach (zeroedIndx; zeroedIndices) {
            foreach (DoF; 0 .. nDoF) {
                if (zeroedIndx == DoF) {
                    M[zeroedIndx, DoF] = 1.0;
                    K[zeroedIndx, DoF] = 1.0;
                } else {
                    M[zeroedIndx, DoF] = 0.0;
                    K[zeroedIndx, DoF] = 0.0;
                    M[DoF, zeroedIndx] = 0.0;
                    K[DoF, zeroedIndx] = 0.0;
                } // end if
            } // end foreach DoF
        } // end foreach zeroedIndx
    } // end GenerateMassStiffnessMatrices

    size_t LocalNodeToGlobalNode(int node, int i, int k) {
        // Get the global node index from the index of a node of an element
        // Note the ordering of the nodes as per Fig 5.8 in
        // "Structural Analysis with the Finite Element Method: Linear Statics, Vol 2"
        switch (node) {
            case 0:
                return (k * (myConfig.Nx + 1) + i);
            case 1:
                return (k * (myConfig.Nx + 1) + i + 1);
            case 2:
                return ((k + 1) * (myConfig.Nx + 1) + i + 1);
            case 3:
                return ((k + 1) * (myConfig.Nx + 1) + i);
            default:
                throw new Error("Something went wrong in assigning the global node index from the local index in FSI.");
        }
    } // end LocalNodeToGlobalNode
 
    Matrix!double LocalStiffnessMatrix(double a, double b, double v) {
        // Allocate memory for the local stiffness matrix
        Matrix!double KL = new Matrix!double(12); KL.zeros();

        // Build the constituitive matrix as per Eq 5.12 in 
        // "Structural Analysis with the Finite Element Method: Linear Statics, Vol 2"
        // The coefficient E/(1-v^2) is applied later
        Matrix!double D = new Matrix!double(3); D.zeros();
        D[0, 0] = 1; D[0, 1] = v;
        D[1, 0] = v; D[1, 1] = 1;
        D[2, 2] = (1 - v) / 2;

        // Use two point quadrature to evaluate the integral
        double[4] xiQuad  = [-1, 1, 1, -1]; xiQuad[]  *= (1 / sqrt(3.0));
        double[4] etaQuad = [-1, -1, 1, 1]; etaQuad[] *= (1 / sqrt(3.0));

        // Allocate memory for the B matrix, which is evaluated at each quad point
        Matrix!double B = new Matrix!double(3, 12);

        // Iterate through the quadrature points
        foreach (quadPoint; 0 .. 4) {
            double xi = xiQuad[quadPoint]; double eta = etaQuad[quadPoint];
            // This is transcribed from Eq. 4.40 in
            // "R for Finite Element Analysis of Size-Dependent Microscale Structures"
            // They are the second and mixed derivatives of the shape functions at each node
            B[0, 0] = 3 * xi * (1 - eta) / (4 * a * a);
            B[0, 1] = (3 * xi - 1) * (1 - eta) / (4 * a);
            B[0, 2] = 0;
            B[0, 3] = 3 * xi * (-1 + eta) / (4 * a * a);
            B[0, 4] = (3 * xi + 1) * (1 - eta) / (4 * a);
            B[0, 5] = 0;
            B[0, 6] = 3 * xi * (-1 - eta) / (4 * a * a);
            B[0, 7] = (3 * xi + 1) * (1 + eta) / (4 * a);
            B[0, 8] = 0;
            B[0, 9] = 3 * xi * (1 + eta) / (4 * a * a);
            B[0,10] = (3 * xi - 1) * (1 + eta) / (4 * a);
            B[0,11] = 0;
            B[1, 0] = 3 * eta * (1 - xi) / (4 * b * b);
            B[1, 1] = 0;
            B[1, 2] = (3 * eta - 1) * (1 - xi) / (4 * b);
            B[1, 3] = 3 * eta * (1 + xi) / (4 * b * b);
            B[1, 4] = 0;
            B[1, 5] = (3 * eta - 1) * (1 + xi) / (4 * b);
            B[1, 6] = 3 * eta * (-1 - xi) / (4 * b * b);
            B[1, 7] = 0;
            B[1, 8] = (3 * eta + 1) * (1 + xi) / (4 * b);
            B[1, 9] = 3 * eta * (-1 + xi) / (4 * b * b);
            B[1,10] = 0;
            B[1,11] = (3 * eta + 1) * (1 - xi) / (4 * b);
            B[2, 0] = (4 - 3 * xi * xi - 3 * eta * eta) / (4 * a * b);
            B[2, 1] = (-3 * xi * xi + 2 * xi + 1) / (4 * b);
            B[2, 2] = (-3 * eta * eta + 2 * eta + 1) / (4 * a);
            B[2, 3] = (-4 + 3 * xi * xi + 3 * eta * eta) / (4 * a * b);
            B[2, 4] = (-3 * xi * xi - 2 * xi + 1) / (4 * b);
            B[2, 5] = (3 * eta * eta - 2 * eta - 1) / (4 * a);
            B[2, 6] = (4 - 3 * xi * xi - 3 * eta * eta) / (4 * a * b);
            B[2, 7] = (3 * xi * xi + 2 * xi - 1) / (4 * b);
            B[2, 8] = (3 * eta * eta + 2 * eta - 1) / (4 * a);
            B[2, 9] = (-4 + 3 * xi * xi + 3 * eta * eta) / (4 * a * b);
            B[2,10] = (3 * xi * xi - 2 * xi - 1) / (4 * b);
            B[2,11] = (-3 * eta * eta - 2 * eta + 1) / (4 * a);

            Matrix!double BDB = dot(dot(transpose(B), D), B);
            KL._data[] += BDB._data[];
        } // end foreach xi, eta
        return KL;
    } // LocalStiffnessMatrix

    Matrix!double LocalMassMatrix(double a, double b) {
        // Allocate memory for the local mass matrix
        Matrix!double ML = new Matrix!double(12); ML.zeros();

        // Here, we only need the shape functions and their first derivatives,
        // so it's easy enough to write out by hand. So we will loop through the nodes,
        // before looping through the quadrature points to form the N matrices
        // Node locations, in the order specified in Fig. 5.8 of
        // "Structural Analysis with the Finite Element Method: Linear Statics, Vol 2"
        double[4] xn = [-1, 1, 1, -1]; double[4] yn = [-1, -1, 1, 1];

        // Quadrature locations
        double[4] xiQuad = xn[] * (1 / sqrt(3.0)); double[4] etaQuad = yn[] * (1 / sqrt(3.0));

        // Allocate memory for the N matrix
        Matrix!double N = new Matrix!double(3, 12);

        // Iterate through quadrature points
        foreach (quadPoint; 0 .. 4) {
            double xi = xiQuad[quadPoint]; double eta = etaQuad[quadPoint];
            // Iterate through nodes on the element
            foreach (i; 0 .. 4) {
                double x = xn[i]; double y = yn[i];
                N[0, i * 3] = (1 + x * xi) * (1 + y * eta) * (2 + x * xi + y * eta - xi * xi - eta * eta) / 8;
                N[0, i * 3 + 1] = a * (xi * xi - 1) * (xi + x) * (1 + y * eta) / 8;
                N[0, i * 3 + 2] = b * (eta * eta - 1) * (eta + y) * (1 + x * xi) / 8;
                N[1, i * 3] = (1 + y * eta) * (2 * xi * x * x + x * (y * eta - 3 * xi * xi - eta * eta + 3) - 2 * xi) / 8;
                N[1, i * 3 + 1] = a * (2 * x * xi + 3 * xi * xi - 1) * (1 + y * eta) / 8;
                N[1, i * 3 + 2] = b * x * (eta * eta - 1) * (eta + y) / 8;
                N[2, i * 3] = (1 + x * xi) * (2 * eta * y * y + y * (x * xi - xi * xi - 3 * eta * eta + 3) - 2 * eta) / 8;
                N[2, i * 3 + 1] = a * y * (xi * xi - 1) * (xi + x) / 8;
                N[2, i * 3 + 2] = b * (2 * y * eta + 3 * eta * eta - 1) * (1 + x * xi) / 8;
            } // end foreach i
            ML.add(dot(transpose(N), N));
        } // end foreach xi, eta

        return ML;
    } // end LocalMassMatrix

    override void UpdateForceVector() {
        // Update the external forcing vector using the fluid pressures at the quadrature
        // locations
        double a = myConfig.length / (2 * myConfig.Nx);
        double b = myConfig.width / (2 * myConfig.Nz);
        double[12] FL;

        // We need to evaluate Eq. 5.46 in 
        // "Structural Analysis with the Finite Element Method: Linear Statics, Vol 2"
        // The integral is computed using two point quadrature. For now, we're going to
        // assume that the external bending moments are 0, so fz is the only non-zero
        // term in the column vector. That means we only need the first column of the 
        // shape matrix. The changes to the global force matrix are only going to be 
        // [N[0, 0] * f, N[1, 0] * f, N[2, 0] * f] where N is the shape matrix

        // Node locations
        double[4] xn = [-1, 1, 1, -1]; double[4] yn = [-1, -1, 1, 1];

        // Quadrature locations
        double[4] xiQuad = xn[] * (1 / sqrt(3.0)); double[4] etaQuad = yn[] * (1 / sqrt(3.0));

        // Iterate through the elements
        size_t globalNodeIndx, globalQuadId;
        double externalForce;
        foreach (k; 0 .. myConfig.Nz) {
            foreach (i; 0 .. myConfig.Nx) {
                // Iterate through nodes on the element to build the local force matrix
                // Reset the local force vector to zeros
                FL[] = 0.0;
                foreach (node; 0 .. 4) {
                    double x = xn[node]; double y = yn[node];
                    // Iterate through quadrature points
                    foreach (quadPoint; 0 .. 4) {
                        double xi = xiQuad[quadPoint]; double eta = etaQuad[quadPoint];
                        // Locate which global quadrature point we're looking at
                        globalQuadId = LocalQuadToGlobalQuad(quadPoint, i, k);

                        // Then compute the net applied pressure
                        externalForce = (southPressureAtQuads[globalQuadId] - northPressureAtQuads[globalQuadId]);

                        // Use the shape functions to compute the additions to the local force matrix
                        FL[3 * node] += externalForce * (1 + x * xi) * (1 + y * eta) * (2 + x * xi + y * eta - pow(xi, 2) - pow(eta, 2)) / 8;
                        FL[3 * node + 1] += externalForce * a * (pow(xi, 2) - 1) * (xi + x) * (1 + y * eta) / 8;
                        FL[3 * node + 2] += externalForce * b * (pow(eta, 2) - 1) * (eta + y) * (1 + x + xi) / 8;

                    } // end foreach quadPoint
                } // end foreach node
                // Add to the global force matrix
                foreach (node; 0 .. 4) {
                    globalNodeIndx = LocalNodeToGlobalNode(node, i, k);
                    F[3 * globalNodeIndx .. 3 * globalNodeIndx + 3] += FL[3 * node .. 3 * node + 3];
                } // end foreach node
            } // end foreach i
        } // end foreach k

        // Scale the vector by a * b
        F[] *= a * b;

        // Set the boundary conditions
        foreach (zeroedIndx; zeroedIndices) {
            F[zeroedIndx] = 0.0;
        }
    }

    size_t LocalQuadToGlobalQuad(size_t quad, size_t i, size_t k) {
        // Convert from the quadrature index on an element to a global quadrature index so
        // we retreive the correct pressure. Order is the same as nodes, but since the
        // elements don't share quadrature points, the indexing is not the same as the nodes.
        switch (quad) {
            case 0:
                return ((2 * k) * myConfig.Nx + i) * 2;
            case 1:
                return ((2 * k) * myConfig.Nx + i) * 2 + 1;
            case 2:
                return ((2 * k + 1) * myConfig.Nx + i) * 2 + 1;
            case 3:
                return ((2 * k + 1) * myConfig.Nx + i) * 2;
            default:
                throw new Error("Something went wrong in assigning the global node index from the local index in FSI.");
        }
    } // end LocalNodeToGlobalNode
        

    override void ConvertToNodeVel() {
        // Convert from the rate of change of the DoFs to velocities usable by the mesh
        foreach (node; 0 .. (myConfig.Nx + 1) * (myConfig.Nz + 1)) {
            FEMNodeVel[node].x = V[node * 3];
            FEMNodeVel[node].y = 0.0;
            FEMNodeVel[node].z = 0.0;
            FEMNodeVel[node].transform_to_global_frame(plateNormal, plateTangent1, plateTangent2);
        }
    } // end convertToNodeVel

    override void DetermineBoundaryConditions(string BCs) {
        // Determine the boundary conditions. The BC string should be 4 characters long,
        // each character denoting a boundary. The order of the BCs are "(-x)(+x)(-z)(+z)".
        // The boundary may be:
        //      F: Free, no constraints on the boundary
        //      C: Clamped, all 3 degrees of freedom are fixed to 0
        //      P: Pinned, the displacement and slope along the boundary are fixed to 0

        // Negative x
        switch (BCs[0]) {
            case 'C':
                foreach (node; 0 .. myConfig.Nz + 1) {
                    // All DoFs
                    foreach (DoF; 0 .. 3) {
                        zeroedIndices ~= (node * (myConfig.Nx + 1)) * 3 + DoF;
                    }
                }
                break;
            case 'P':
                foreach (node; 0 .. myConfig.Nz + 1) {
                    // The displacement DoF
                    zeroedIndices ~= (node * (myConfig.Nx + 1)) * 3;
                    // The z slope is 0, which is the 3rd DoF
                    zeroedIndices ~= (node * (myConfig.Nx + 1)) * 3 + 2;
                }
                break;
            case 'F':
                break;
            default:
                throw new Error("Unrecognised BC specification in FSI; should be 'F', 'C' or 'P'");
        }

        // Positive x
        switch (BCs[1]) {
            case 'C':
                foreach (node; 0 .. myConfig.Nz + 1) {
                    // All DoFs
                    foreach (DoF; 0 .. 3) {
                        zeroedIndices ~= (node * (2 * myConfig.Nx + 1)) * 3 + DoF;
                    }
                }
                break;
            case 'P':
                foreach (node; 0 .. myConfig.Nz + 1) {
                    // The displacement DoF
                    zeroedIndices ~= (node + (2 * myConfig.Nx + 1)) * 3;
                    // The z slope is 0, which is the 3rd DoF
                    zeroedIndices ~= (node + (2 * myConfig.Nx + 1)) * 3 + 2;
                }
                break;
            case 'F':
                break;
            default:
                throw new Error("Unrecognised BC specification in FSI; should be 'F', 'C' or 'P'");
        }

        // Negative z
        switch (BCs[2]) {
            case 'C':
                foreach (node; 0 .. myConfig.Nz + 1) {
                    // All DoFs
                    foreach (DoF; 0 .. 3) {
                        zeroedIndices ~= node * 3 + DoF;
                    }
                }
                break;
            case 'P':
                foreach (node; 0 .. myConfig.Nz + 1) {
                    // The displacement DoF
                    zeroedIndices ~= node * 3;
                    // The x slope is 0, which is the 2nd DoF
                    zeroedIndices ~= node * 3 + 1;
                }
                break;
            case 'F':
                break;
            default:
                throw new Error("Unrecognised BC specification in FSI; should be 'F', 'C' or 'P'");
        }
        
        // Positive z
        switch (BCs[2]) {
            case 'C':
                foreach (node; 0 .. myConfig.Nz + 1) {
                    // All DoFs
                    foreach (DoF; 0 .. 3) {
                        zeroedIndices ~= (myConfig.Nz * 2 * (myConfig.Nx + 1) + node) * 3 + DoF;
                    }
                }
                break;
            case 'P':
                foreach (node; 0 .. myConfig.Nz + 1) {
                    // The displacement DoF
                    zeroedIndices ~= (myConfig.Nz * 2 * (myConfig.Nx + 1) + node) * 3;
                    // The x slope is 0, which is the 2nd DoF
                    zeroedIndices ~= (myConfig.Nz * 2 * (myConfig.Nx + 1) + node) * 3 + 1;
                }
                break;
            case 'F':
                break;
            default:
                throw new Error("Unrecognised BC specification in FSI; should be 'F', 'C' or 'P'");
        }
    } // end determineBoundaryConditions

    override void WriteFSIToFile(size_t tindx) {
        // Initialise the gzipped writer
        auto outfile = new GzipOut(format("FSI/t%04d.gz", tindx));
        auto writer = appender!string();

        // Set the header to describe the columns (w = displacement, theta_x = x slope, theta_z = z slope)
        formattedWrite(writer, "# w theta_x theta_z dxdt dtheta_xdt dtheta_zdt\n");
        // Write the position and velocities for each DoF
        foreach (node; 0 .. (myConfig.Nx + 1) * (myConfig.Nz + 1)) {
            formattedWrite(writer, "%.18e %1.8e %1.8e %1.8e %1.8e %1.8e\n", X[node*3].re, X[node*3+1], X[node*3+2].re, V[node*3].re, V[node*3+1].re, V[node*3+2].re);
        }
        outfile.compress(writer.data);
        outfile.finish();
    } // end WriteFSIToFile

    override void ReadFSIFromFile(size_t tindx) {
        // Open the Gzip reader
        auto readFileByLine = new GzipByLine(format("FSI/t%04d.gz", tindx));

        // Pop the header line
        readFileByLine.popFront();
        double[6] line;
        // Take out each line and put into the relevant locations in X, V
        foreach (node; 0 .. (myConfig.Nx + 1) * (myConfig.Nz + 1)) {
            line = map!(to!double)(splitter(readFileByLine.front())).array; readFileByLine.popFront();
            X[node*3 .. (node+1)*3] = to!(double[3])(line[0 .. 3]);
            V[node*3 .. (node+1)*3] = to!(double[3])(line[3 .. 6]);
        }
    } // end ReadFSIFromFile

    override string GetHistoryHeader() {
        // Get the history header string- should look basically the same as the writer header,
        // with the inclusion of t in the first slot
        return "# t w theta_x theta_z dwdt dtheta_xdt dtheta_zdt\n";
    } // end GetHistoryHeader

    override void WriteFSIToHistory(double t) {
        // Write the node ODE solutions to history file

        foreach (node; myConfig.historyNodes) {
            append(format("FSI/hist/%04d.dat", node), format("%1.18e %1.18e %1.18e %1.18e %1.18e %1.18e %1.18e\n", t, X[node * 3], X[node * 3 + 1], X[node * 3 + 2], V[node * 3], V[node * 3 + 1], V[node * 3 + 2]));
        }
    } // end WriteFSIToHistory
}
