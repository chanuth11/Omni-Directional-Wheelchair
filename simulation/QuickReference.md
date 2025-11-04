# Omni-Directional Chair Simulation - Quick Reference Card

## 🚀 Quick Start Commands

```matlab
% 1. Initialize parameters
run('init_omni_chair.m')

% 2. Open/create model
open_system('OmniChair_Simulation')
% OR create new: Simulink → Blank Model

% 3. Run simulation
sim('OmniChair_Simulation')

% 4. Open 3D visualization
smexplore('OmniChair_Simulation')
```

---

## 📦 Essential Simulink Blocks

### From: `Simscape Multibody`

| Block | Location | Purpose |
|-------|----------|---------|
| **World Frame** | Frames and Transforms | Gravity reference |
| **Mechanism Configuration** | Utilities | Global settings |
| **Solid (Sphere)** | Body Elements | Main ball |
| **Solid (Cylinder)** | Body Elements | Omni wheels |
| **Brick Solid** | Body Elements | Platform, ground |
| **6-DOF Joint** | Joints | Free-moving ball |
| **Revolute Joint** | Joints | Wheel rotation |
| **Weld Joint** | Joints | Fix ground |
| **Bushing Joint** | Joints | Flexible connection |
| **Rigid Transform** | Frames and Transforms | Position bodies |
| **Transform Sensor** | Sensors & Actuators | Measure position/velocity |

### From: `Simscape Multibody Contact Forces Library`

| Block | Location | Purpose |
|-------|----------|---------|
| **Sphere to Sphere Force** | 3D | Ball-to-wheel contact |
| **Sphere to Plane Force** | 3D | Ball-to-ground contact |

---

## 🔧 Critical Parameters (from `init_omni_chair.m`)

```matlab
% Geometry
main_ball.rad = 0.1016;           % 8" diameter ball
omni_wheel.rad = 0.0254;          % 2" diameter wheel

% Masses
system.total_mass = 75;           % kg (approx)
user.mass = 70;                   % kg

% Contact Forces
contact.k_stiffness = 1e6;        % N/m
contact.b_damping = 1e4;          % N/(m/s)
contact.mu_static = 0.8;          % friction
contact.mu_kinetic = 0.6;

% Wheel Positions (120° apart)
wheel1: (0.08, 0, -0.11) m        % Front
wheel2: (-0.04, 0.069, -0.11) m   % Left-back
wheel3: (-0.04, -0.069, -0.11) m  % Right-back

% Control
control.sample_rate = 100;        % Hz
control.Kp_balance = 50;

% Simulation
sim.gravity_vector = [0; 0; -9.81]
sim.time_step_max = 0.001;        % 1ms
sim.solver = 'ode23t';
```

---

## 🎯 Model Building Checklist

### Phase 1: Foundation
- [ ] Add **World Frame** (set gravity `[0, 0, -9.81]`)
- [ ] Add **Mechanism Configuration** (leave unconnected)
- [ ] Add **Ground Plane** (Brick Solid + Weld to World)

### Phase 2: Main Ball
- [ ] Add **Solid (Sphere)** for main ball
- [ ] Set radius: `main_ball.rad`
- [ ] Add **6-DOF Joint** (World → Ball)
- [ ] Set initial position: `[0, 0, 0.15]`

### Phase 3: Omni Wheels (×3)
For each wheel:
- [ ] Add **Solid (Cylinder)** for wheel
- [ ] Add **Rigid Transform** (position from World)
  - Wheel 1: `[wheel1.x, wheel1.y, wheel.z_offset]`
  - Wheel 2: `[wheel2.x, wheel2.y, wheel.z_offset]`
  - Wheel 3: `[wheel3.x, wheel3.y, wheel.z_offset]`
- [ ] Add **Revolute Joint** (Transform → Wheel)
- [ ] Add **Joint Actuator** (torque input)

### Phase 4: Contact Forces (×3)
For each wheel:
- [ ] Add **Sphere to Sphere Force**
- [ ] Connect Base (B) to main ball frame
- [ ] Connect Follower (F) to wheel frame
- [ ] Configure:
  - Base radius: `main_ball.rad`
  - Follower radius: `omni_wheel.rad`
  - Stiffness: `1e6`, Damping: `1e4`
  - Friction: `0.8` static, `0.6` kinetic

### Phase 5: Platform & User
- [ ] Add **Brick Solid** for platform
- [ ] Add **Bushing Joint** (Ball → Platform)
- [ ] Add **Point Mass** for user (position above platform)

### Phase 6: Sensors & Control
- [ ] Add **Transform Sensor** on ball (position, velocity)
- [ ] Add **Transform Sensor** on platform (orientation)
- [ ] Add **PS-Simulink Converter** blocks
- [ ] Create controller subsystem
- [ ] Connect controller to motor actuators

### Phase 7: Visualization
- [ ] Add **Scope** blocks for signals
- [ ] Configure **Mechanics Explorer** view

---

## 🧪 Testing Sequence

### Test 1: Static Balance (Pass/Fail)
```matlab
% All motor torques = 0
% Expected: Ball settles on wheels, stable
```
**✓ Pass if:** System comes to rest, no motion

### Test 2: Single Wheel Drive
```matlab
% Wheel 1: constant torque (2 Nm)
% Wheel 2, 3: 0 Nm
% Expected: Ball rolls forward
```
**✓ Pass if:** Ball moves in +X direction

### Test 3: Coordinated Motion
```matlab
% All wheels: same torque (2 Nm)
% Expected: Ball moves forward
```
**✓ Pass if:** Ball translates linearly

### Test 4: Balance Control
```matlab
% Initial tilt: [0.05, 0, 0.15]  (5cm offset)
% Controller: ON
% Expected: Returns to center
```
**✓ Pass if:** Ball returns to [0, 0, ~0.15] within 2s

### Test 5: Speed Test
```matlab
% Command: 2 m/s forward
% Expected: Achieves speed within 2s
```
**✓ Pass if:** Velocity ≥ 1.8 m/s after 2s

---

## 🔍 Debugging Guide

| Problem | Likely Cause | Solution |
|---------|--------------|----------|
| **Won't start** | Missing World Frame | Add World Frame with gravity |
| | Over-constrained | Check for redundant joints |
| **Explodes** | Time step too large | Set max step = 1e-4 |
| | Initial penetration | Check geometry overlap |
| | Low damping | Increase `contact.b_damping` |
| **Won't move** | Contact forces off | Check library installed |
| | Motors not connected | Verify actuator connections |
| | Friction too high | Lower `mu_kinetic` |
| **Wheels slip** | Friction too low | Increase `mu_static` |
| | Normal force low | Check positioning |
| **Unstable** | Control gains wrong | Reduce `Kp_balance` |
| | CoM too high | Lower user mass position |
| **Too slow** | Complex geometry | Use simple shapes |
| | Small time step | Increase max step (carefully) |

---

## 📊 Expected Values (Sanity Check)

| Quantity | Expected Value | Check |
|----------|----------------|-------|
| Ball height (rest) | ~0.13-0.15 m | Scope plot |
| Normal force per wheel | ~245 N (75kg/3) | Contact force output |
| Ball velocity (max) | 2-2.5 m/s | Transform sensor |
| Wheel speed (max) | ~80-100 rad/s | Revolute joint sensor |
| Platform tilt (rest) | <1° | Orientation sensor |
| Simulation time (10s) | <30s real time | MATLAB timer |

---

## 🎨 Simscape Library Paths

**Quick Copy-Paste Paths:**
```
sm_lib/Frames and Transforms/World Frame
sm_lib/Frames and Transforms/Rigid Transform
sm_lib/Body Elements/Solid
sm_lib/Joints/6-DOF Joint
sm_lib/Joints/Revolute Joint
sm_lib/Joints/Weld Joint
sm_lib/Joints/Bushing Joint
sm_lib/Sensors & Actuators/Transform Sensor
Contact_Forces_Lib/3D/Sphere to Sphere Force
```

---

## 🚨 Common Error Messages

**"Inconsistent initial conditions"**
→ Wheels and ball overlapping at t=0. Move wheels further away.

**"Derivative of state is Inf or NaN"**
→ Collision too stiff. Reduce `k_stiffness` or increase `b_damping`.

**"Solver failed to converge"**
→ Use `ode15s` (stiff solver) or reduce max time step.

**"Algebraic loop"**
→ Add small inertia to all bodies. Check for direct feedthrough.

**"Contact forces = 0"**
→ Library not installed, or frames not connected properly.

---

## ⚙️ Solver Settings (Quick Config)

**Model Settings (Ctrl+E):**
```
Solver Tab:
  Type: Variable-step
  Solver: ode23t (or ode15s for very stiff)
  Max step size: 0.01 (10ms)
  Relative tolerance: 1e-4
  
Advanced:
  Zero-crossing: on
  Consecutive min steps: 5
```

---

## 📈 Success Criteria

Your simulation is working when:
1. ✓ Runs without errors for 10+ seconds
2. ✓ Ball maintains contact with all 3 wheels
3. ✓ System comes to stable rest with motors off
4. ✓ Ball responds to motor commands
5. ✓ Platform remains mostly level (±5°)
6. ✓ Can achieve >2 m/s velocity
7. ✓ Controller recovers from 5cm tilt within 2s

---

## 🆘 Help Resources

**In MATLAB:**
```matlab
help init_omni_chair        % Parameter descriptions
doc simscape                % Simscape documentation
smdoc_four_bar              % Example Simscape model
smimport                    % Import CAD help
```

**Files:**
- `simulationWalkthrough.md` - Full 35-step tutorial
- `README.md` - Complete documentation
- `init_omni_chair.m` - All parameters

**Team:**
- Joseph (Control simulation)
- Ameen (CAD geometry)
- Samuel (System specs)

---

**Print this page and keep handy while working in Simulink!** 📄

Last Updated: 2025-11-04

