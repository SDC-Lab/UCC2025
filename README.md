# UCC2025
This is the repository for UCC 2025 Tutorial: Federated Learning in Orbital Edge Computing

## Federated Learning in Orbital Edge Computing  

This repository contains the hands-on materials for the **UCC 2025 Tutorial on Federated Learning in Orbital Edge Computing**.  
The tutorial demonstrates how federated learning (FL) workflows can be adapted to **LEO satellite constellations**, focusing on the interplay between **distributed learning** and **orbital communication constraints**.

---

## ⭐ What Participants Will Learn

This hands-on tutorial is organized into two main components:

---

### **1. Federated Learning with Flower (Python)**

Participants will implement a complete FL pipeline using the **Flower** framework, including:

- Loading and preprocessing the EuroSat dataset  
- Defining client-side training and evaluation procedures  
- Simulating multiple FL clients  
- Running round-based federated training  
- Observing global aggregation and convergence dynamics  

This section helps participants understand:

- How FL operates end-to-end  
- Client–server communication  
- Scalability and heterogeneity in distributed systems  

All Python code is designed to run directly in **Google Colab**.

---

### **2. Satellite–Ground-Station Visibility Simulation (MATLAB)**

This optional module illustrates how **orbital geometry** and **GS visibility windows** influence federated learning on LEO satellite constellations.

Uploaded materials include:

- `UCC_Tutorial_Matlab.m` — Computes satellite–GS visibility patterns and identifies potential master satellites  
- `Visualization.mp4` — Demonstrates constellation behavior and ground-station contact intervals  
  (See uploaded files in repository)

Topics covered:

- Modeling a Walker Delta constellation  
- Computing GS pass windows (Canberra GS)  
- Selecting master satellites based on coverage  
- Understanding how orbital constraints shape FL synchronization  

This section connects real orbital dynamics with distributed learning design.
