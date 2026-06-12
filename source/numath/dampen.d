/**
    NuMath Dampening functions


    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:    $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:
        Luna Nielsen
*/
module numath.dampen;
import numath.math : pow, max, clamp, sqrt;
import numath.vector;

@safe pure nothrow @nogc:

/**
    Smoothly interpolates $(D current) towards $(D target).

    This version uses a simplified algorithm which does not take velocity into account.

    Params:
        current =   The current position
        target =    The target position
        delta =     The time since the last dampening step.
        maxSpeed =  The maximum units that can be moved in this iteration.

    Returns:
        The derived position for this iteration.
*/
V dampen(V, T)(V current, V target, T delta, T maxSpeed = 50)
if(isVector!V && __traits(isFloating, T)) {
    V out_ = current;
    V diff = current - target;

    // Actual damping
    if (diff.length > 0) {
        V direction = (diff).normalized;

        T speed = min(
            max(0.001, 5.0*(target - current).length) * delta,
            maxSpeed
        );
        V velocity = direction * speed;

        // Set target out
        out_ = ((target + diff) - velocity);

        // Handle overshooting
        diff = target - current;
        if (diff.dot(out_ - target) > 0.0f) {
            out_ = target;
        }
    }
    return out_;
}


/**
    Smoothly interpolates $(D current) towards $(D target).

    This version uses a simplified algorithm which does not take velocity into account.

    Params:
        current =   The current position
        target =    The target position
        delta =     The time since the last dampening step.
        maxSpeed =  The maximum units that can be moved in this iteration.

    Returns:
        The derived position for this iteration.
*/
T dampen(T)(T current, T target, T delta, T maxSpeed = 50)
if(__traits(isFloating, T)) {
    T out_ = current;
    T diff = current - target;
    T diffLen = sqrt(diff^^2);
    T direction = diff/diffLen;

    // Actual damping
    if (diffLen > 0) {

        T speed = min(
            max(0.001, 5.0*sqrt((target - current)^^2)) * delta,
            maxSpeed
        );
        T velocity = direction * speed;

        // Set target out
        out_ = ((target + diff) - velocity);

        // Handle overshooting
        diff = target - current;
        if (diff * (out_ - target) > 0.0f) {
            out_ = target;
        }
    }
    return out_;
}

/**
    Smoothly interpolates $(D current) towards $(D target).

    This algorithm uses a critial damped harmonic oscillator to smooth values.

    Params:
        current =           The current position
        target =            The target position
        currentVelocity =   The current velocity
        smoothTime =        The estimated time of arrival, lower value will make $(D current) arrive faster.
        maxSpeed =          The maximum units that can be moved in this iteration.
        deltaTime =         The time since the last dampening step.

    Returns:
        The derived position for this iteration.
*/
V smoothDamp(V, T)(V current, V target, ref V currentVelocity, T smoothTime, T maxSpeed, T deltaTime)
if (isVector!V && __traits(isFloating, T)) {
    V out_;

    smoothTime = max(0.0001f, smoothTime);
    T hSmoothTime = 2.0 / smoothTime;
    T smoothDelta = hSmoothTime * deltaTime;
    smoothDelta = 1.0 / (1.0 + smoothDelta + 0.48 * smoothDelta * smoothDelta + 0.235 * smoothDelta * smoothDelta * smoothDelta);

    V diff = current - target;
    V startTarget = target;

    // Calculate approprate speed
    T actualMaxSpeed = maxSpeed * smoothTime;
    T sqSpeed = actualMaxSpeed * actualMaxSpeed;
    T diffLength = diff.length;
    if (diffLength > sqSpeed) {
        T squaredLength = sqrt(diffLength);
        static foreach(i; 0..V.dimenson) {
            diff.vector[i] /= squaredLength * actualMaxSpeed;
        }
    }

    // Calculate new velocity
    V newVelocity = (currentVelocity + hSmoothTime * diff) * deltaTime;
    currentVelocity = (currentVelocity - hSmoothTime * newVelocity) * smoothDelta;

    // Calculate new position
    target = current-diff;
    out_ = target + (diff + newVelocity) * smoothDelta;
    diff = startTarget - current;
    V fDeltaUnit = out_ - startTarget;

    // Handle overshooting
    if (diff.dot(fDeltaUnit) > 0.0) {
        out_ = startTarget;
        currentVelocity = fDeltaUnit / deltaTime;
    }
    return out_;
}

/**
    Smoothly interpolates $(D current) towards $(D target).

    This algorithm uses a critial damped harmonic oscillator to smooth values.

    Params:
        current =           The current position
        target =            The target position
        currentVelocity =   The current velocity
        smoothTime =        The estimated time of arrival, lower value will make $(D current) arrive faster.
        maxSpeed =          The maximum units that can be moved in this iteration.
        deltaTime =         The time since the last dampening step.

    Returns:
        The derived position for this iteration.
*/
T smoothDamp(T)(T current, T target, ref T currentVelocity, T smoothTime, T maxSpeed, T deltaTime)
if(__traits(isFloating, T)) {
    T out_;

    smoothTime = max(0.0001f, smoothTime);
    T hSmoothTime = 2.0 / smoothTime;
    T smoothDelta = hSmoothTime * deltaTime;
    smoothDelta = 1.0 / (1.0 + smoothDelta + 0.48 * smoothDelta * smoothDelta + 0.235 * smoothDelta * smoothDelta * smoothDelta);

    T diff = current - target;
    T startTarget = target;

    // Calculate approprate speed
    T actualMaxSpeed = maxSpeed * smoothTime;
    diff = clamp(diff, -actualMaxSpeed, actualMaxSpeed);

    // Calculate new velocity
    T newVelocity = (currentVelocity + hSmoothTime * diff) * deltaTime;
    currentVelocity = (currentVelocity - hSmoothTime * newVelocity) * smoothDelta;

    // Calculate new position
    target = current-diff;
    out_ = target + (diff + newVelocity) * smoothDelta;
    diff = startTarget - current;

    // Handle overshooting
    if (diff * (out_ - startTarget) > 0.0) {
        out_ = startTarget;
        currentVelocity = (out_ - startTarget) / deltaTime;
    }
    return out_;
}