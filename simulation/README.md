# Omni-Directional Chair - Simulation

## Overview
This directory contains MATLAB/Simulink simulation files for the omni-directional wheelchair basketball chair project.

## Files

### Documentation
- **`simulationWalkthrough.md`** - Complete 35-step tutorial for building the simulation from scratch
- **`README.md`** - This file

### MATLAB Scripts
- **`init_omni_chair.m`** - Initialization script with all simulation parameters
  - Run this before starting the simulation
  - Contains all physical parameters, kinematics, and configuration

### CAD Files (`cadFiles/`)
- **`Ball.STEP`** - Main ball geometry (8" diameter)
- **`omni_wheel.STEP`** - Omni wheel geometry (2" diameter)
- **`Structure.STEP`** - Platform/frame structure

### Example Reference (`simulinkExample/`)
- **`Frict3D06BallonBalls/`** - Example model showing ball-on-balls contact forces
  - Useful reference for understanding contact force blocks
  - Shows 1 large ball balanced on 4 smaller spinning balls

## Quick Start

### Prerequisites
Ensure you have these MATLAB toolboxes installed:
1. Simulink
2. Simscape
3. Simscape Multibody
4. Simscape Multibody Contact Forces Library

### Getting Started

#### Option 1: Build From Scratch (Recommended for Learning)
1. Open MATLAB in this directory
2. Read `simulationWalkthrough.md`
3. Follow the 35 steps to build your model
4. Run `init_omni_chair.m` before simulating

#### Option 2: Quick Setup
1. Run initialization script:
   ```matlab
   run('init_omni_chair.m')
   ```
2. Create a new Simulink model: `OmniChair_Simulation.slx`
3. Add the core components:
   - World Frame (with gravity)
   - Main Ball (8" diameter sphere)
   - 3 Omni Wheels (2" diameter, positioned 120° apart)
   - Sphere-to-Sphere Contact Force blocks
   - Platform and user mass
4. Configure and run

## System Architecture

```
┌─────────────────────────────────────┐
│         User Mass (70 kg)           │
│              ↓                       │
│    Platform (5 kg, 300x300 mm)      │
│         Connected to                 │
│    Main Ball (8" diameter)          │
│         Resting on                   │
│  ╔═══╗     ╔═══╗     ╔═══╗          │
│  ║ W1║     ║ W2║     ║ W3║          │  W1, W2, W3 = Omni Wheels
│  ╚═══╝     ╚═══╝     ╚═══╝          │  (2" dia, 120° spacing)
│    ↓         ↓         ↓             │
│  Motor1   Motor2   Motor3           │
│              ↓                       │
│         Ground Plane                 │
└─────────────────────────────────────┘
```

## Key Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| Main Ball Diameter | 8" (0.203 m) | Based on design spec |
| Omni Wheel Diameter | 2" (0.051 m) | Estimated |
| Total System Mass | ~75 kg | Ball + wheels + platform + user |
| Contact Stiffness | 1e6 N/m | Rubber-on-rubber |
| Friction Coefficient | 0.8 (static) | Rubber contact |
| Max Speed Target | 5 mph (2.24 m/s) | Design specification |
| Control Sample Rate | 100 Hz | 10ms update period |

## Simulation Workflow

```
1. Initialize Parameters
   ↓
2. Build Physical Model (Bodies, Joints, Contact Forces)
   ↓
3. Add Sensors (Position, Velocity, Orientation)
   ↓
4. Implement Control System (Motor Controller)
   ↓
5. Configure Solver & Run
   ↓
6. Visualize Results (Mechanics Explorer, Scopes)
   ↓
7. Analyze & Tune
```

## Control Strategy

### Balance Control
The system uses a feedback loop to maintain balance:
1. **IMU Sensor** measures platform tilt (pitch, roll)
2. **Controller** calculates correction velocity
3. **Kinematics** converts to 3 wheel velocities
4. **Motors** apply torques to wheels
5. **Ball moves** to restore balance

### Kinematics
For 3-wheel omnidirectional system:
```
[w1]   [K11  K12  K13]   [Vx  ]
[w2] = [K21  K22  K23] × [Vy  ]
[w3]   [K31  K32  K33]   [Ωz  ]
```
Where:
- `w1, w2, w3` = wheel angular velocities
- `Vx, Vy` = platform velocity (X, Y)
- `Ωz` = platform rotation rate
- `K` = kinematics matrix (calculated in `init_omni_chair.m`)

## Testing Procedure

### Phase 1: Static Tests
1. **Gravity Test** - Ball settles on wheels, no motion
2. **Contact Force Check** - Verify normal forces balanced
3. **Stability Test** - Small perturbations should be stable

### Phase 2: Single Motor Tests
4. **Individual Wheel Drive** - Each motor independently
5. **Verify Ball Movement** - Check direction and speed
6. **Friction Check** - Wheels should grip, not slip

### Phase 3: Coordinated Tests
7. **Straight Line Motion** - All wheels same direction
8. **Rotation** - Wheels opposite directions
9. **Diagonal Motion** - Combined translation

### Phase 4: Control System Tests
10. **Balance Recovery** - Tilt platform, controller corrects
11. **User Input Response** - Command velocity, measure response
12. **Disturbance Rejection** - Apply external force, recover

### Phase 5: Performance Tests
13. **Max Speed Test** - Achieve 5 mph target
14. **Acceleration Test** - 0-5 mph in 2 seconds
15. **Stability Under Load** - Maintain balance with collisions

## Tuning Guide

### If Ball Doesn't Balance:
- Increase control gains (`control.Kp_balance`)
- Check CoM height (should be reasonable)
- Verify contact forces are active
- Check wheel positioning (symmetric?)

### If System is Too Bouncy:
- Increase contact damping (`contact.b_damping`)
- Reduce control gains
- Lower time step

### If Wheels Slip:
- Increase friction coefficient (`contact.mu_static`)
- Increase contact stiffness (to a point)
- Check that normal forces are sufficient

### If Simulation is Slow:
- Use simpler geometries (spheres/cylinders vs CAD)
- Increase max time step (carefully)
- Reduce logging frequency
- Use Accelerator mode

### If Simulation Crashes:
- Reduce max time step to 1e-4 or smaller
- Check for initial penetrations (wheels into ball)
- Use stiffer solver (`ode15s`)
- Add small damping everywhere

## Expected Results

### Successful Simulation Shows:
- ✓ Ball rests stably on 3 wheels
- ✓ Contact forces are ~245N per wheel (75kg / 3)
- ✓ Platform remains level when motors off
- ✓ Platform can be tilted and recovered
- ✓ Ball moves in response to motor commands
- ✓ System achieves 2+ m/s velocity
- ✓ Controller maintains balance during motion

### Physics Validation:
- Ball velocity = wheel_speed × wheel_radius (within 10%)
- Total vertical force = system_mass × gravity
- Power consumption = torque × angular_velocity
- Response time < 100ms (design spec)

## Next Steps

After successful simulation:
1. **Parameter Optimization** - Sweep contact stiffness, friction, control gains
2. **Control System Design** - Implement PID, test different algorithms
3. **Hardware-in-Loop** - Connect to Arduino for real-time testing
4. **Physical Prototype Correlation** - Compare sim to real measurements

## Troubleshooting

### Common Error Messages

**"Algebraic loop detected"**
- Solution: Add small mass/inertia to all bodies
- Add computational delay (unit delay block)

**"Inconsistent initial conditions"**
- Solution: Ensure no overlapping geometries at t=0
- Position wheels slightly away from ball initially

**"Solver failed to converge"**
- Solution: Use smaller time step
- Switch to `ode15s` or `ode23t`
- Add damping to all joints

**"Contact forces are zero"**
- Solution: Check Contact Forces Library is installed
- Verify frame connections (Base/Follower)
- Ensure geometries are close enough (<1mm gap)

## Resources

### MATLAB Documentation
- [Simscape Multibody Getting Started](https://www.mathworks.com/help/sm/getting-started-with-simscape-multibody.html)
- [Contact Forces Library](https://www.mathworks.com/matlabcentral/fileexchange/47417-simscape-multibody-contact-forces-library)

### Project Documentation
- `docs/PrelinimaryDesignPresentation.md` - Design specifications
- `docs/Component_Selection.md` - Motor calculations
- `docs/ProjectPlan.md` - Overall project timeline

### Example Models
- `simulinkExample/Frict3D06BallonBalls/` - Ball-on-balls contact
- MATLAB Examples: Type `smdoc_four_bar` for other Simscape examples

## Team Notes

- **Joseph**: Primary simulation developer
- **Samuel**: System parameters and specifications
- **Ameen**: CAD geometry integration
- **Chanuth & Adesh**: Motor/sensor parameters

## Changelog

- **2025-11-04**: Initial simulation framework created
  - Created walkthrough documentation
  - Created initialization script
  - Defined all system parameters
  
---

**Project:** MTE 481 Capstone - Omni-Directional Wheelchair  
**Team:** Group 52  
**Last Updated:** 2025-11-04

