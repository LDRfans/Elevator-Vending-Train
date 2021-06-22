# Team 1 Project 1 Week 4 Report
Participants: Tiansu Chen(R), Chenyang Zhang(D), Ziqi Gao(V).
Meeting Date: 2021.03.19
Project Leader: Tiansu Chen

## Summary
Things finished since last meeting:

+ Tiansu Chen: Restate the problem, propose several basic requirement and advanced requirement in natural language and discuss the problem.
+ Chenyang Zhang: Discuss the problem.
+ Ziqi Gao: Discuss the problem.

## Questions prepared for the instructor team
+ Q1: How does sensor act with our program? Are they just implemented functions?
+ Q2: Can we add sensors such as weight detection and object detection?
+ Q3: How should we deal with the emergency situation such as:
  + Power cut and conflagration.
  + Manually stop by the passengers.

## Action Items (Plan for the next week):
+ Tiansu Chen: Draw the basic UML.
+ Chenyang Zhang: Help S~1~, discuss and answer questions together.
+ Ziqi Gao: Help S~1~, discuss and answer questions together.

## Content

### 1. Problem Restatement

#### 1.1 Environment

+ A building with 3 floors (1, 2, 3) and 1 basement (-1).
+ 2 elevators A and B(coordinated), only A can reach the basement (-1).
+ Physical environment is considered (all actions need time).

#### 1.2 User Interface

+ Inside Button Panel
  + Floors ((-1, 1, 2, 3) / (1, 2, 3)).
  + Control (open the door, close the door, alarm).
+ Inside Display
  + Current Floor (-1 / 1 / 2 / 3).
  + Current Direction ($\uparrow$ / $\downarrow$).

+ Outside Button Panel
  + Call (up / down / (up, down))

+ Outside Display
  + Current Floor of A (-1 / 1 / 2 / 3) and B (1 / 2 / 3).

#### 1.3 Sensors

+ Door fully open, door closed (T / F).
+ Elevator move by the sensor (T / F).

#### 1.4 Controller Actions

+ Open / Close door.
+ Move up / down.
+ Stop.

### 2. Basic Requirement

+ Transporting Functionality
  + Move to the correct floor and open the door.
  + **Never** open the door **towards the wall** or **moving**.
  + Keep moving towards the **current direction** as far as possible.

+ Security Functionality
  + Reasonable moving speed (1.0 m/s).
  + Reasonable acceleration (0.5 m/s^2^).
+ Dispatchment
  + Call at basement (-1) has **priority** to call elevator A.
  + The elevator call is disposed by the **nearest available** elevator.

### 3. Advanced Requirement

+ Deal with the **emergency** situation (stop immediately / stop at the next floor).

+ Keep stopping when **overloading**. (maybe additional sensors).

+ Stop closing the door if **blocked**. (maybe additional sensors).