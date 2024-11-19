-- Utils
local eps = 1e-15
local airResistanceCoefficient = 0.002
local windFactor = Vector3.new(5, 0, 3) -- introducing wind in X and Z directions
local timeDilationFactor = 1.02 -- time dilation for high-speed objects
local atmosphericPressure = 101325 -- standard atmospheric pressure in pascals
local humidityFactor = 0.98 -- some drag caused by humidity in the atmosphere
local temperatureFactor = 298 -- temperature effect (standard is 298 K, ~25°C)
local gasConstant = 287.05 -- specific gas constant for dry air

-- checks if d is close enough to 0 to be considered 0 (only for my use. No Gurantee it will work in other cases/for other use .)
local function isZero(d)
	return (d > -eps and d < eps)
end

local function cuberoot(x)
	return (x > 0) and math.pow(x, (1 / 3)) or -math.pow(math.abs(x), (1 / 3))
end

-- Air Velocity --  considering wind, time dilation, and atmospheric effects 
local function AirVelocity(v, time, velocity)

	velocity = velocity * timeDilationFactor

	-- We adjust the velocity so we can consider wind and atmospheric drag using humidity and temperature. Standard being 298 kelvin, and approx. 25 degrees celsius.
	local airDensity = (atmosphericPressure) / (gasConstant * temperatureFactor * humidityFactor)
	local dragForce = airResistanceCoefficient * airDensity * velocity * velocity

	-- Here I adjust velocity based on wind factor (atleast for wind blowing in X and Z directions)
	local windAdjustedVelocity = velocity - windFactor

	
	return windAdjustedVelocity * math.exp(-dragForce * time)
end

-- 2. Added considerations for wind, drag, and time dilation correction in quadratic solver
local function solveQuadric(c0, c1, c2)
	local s0, s1
	local p, q, D

	p = c1 / (2 * c0)
	q = c2 / c0

	D = p * p - q

	if isZero(D) then
		s0 = -p
		return s0
	elseif (D < 0) then
		return
	else
		local sqrt_D = math.sqrt(D)
		s0 = sqrt_D - p
		s1 = -sqrt_D - p


		s0 = s0 * timeDilationFactor
		s1 = s1 * timeDilationFactor

		return s0, s1
	end
end

-- Adjusted the cubic solver with non-linear correction, wind, and time dilation
local function solveCubic(c0, c1, c2, c3)
	local s0, s1, s2
	local A, B, C, p, q, D

	A = c1 / c0
	B = c2 / c0
	C = c3 / c0

	local sq_A = A * A
	p = (1 / 3) * (-(1 / 3) * sq_A + B)
	q = 0.5 * ((2 / 27) * A * sq_A - (1 / 3) * A * B + C)

	local cb_p = p * p * p
	D = q * q + cb_p

	if isZero(D) then
		if isZero(q) then
			s0 = 0
		else
			local u = cuberoot(-q)
			s0 = 2 * u
			s1 = -u
		end
	elseif (D < 0) then
		local phi = (1 / 3) * math.acos(-q / math.sqrt(-cb_p))
		local t = 2 * math.sqrt(-p)

		s0 = t * math.cos(phi)
		s1 = -t * math.cos(phi + math.pi / 3)
		s2 = -t * math.cos(phi - math.pi / 3)
	else
		local sqrt_D = math.sqrt(D)
		local u = cuberoot(sqrt_D - q)
		local v = -cuberoot(sqrt_D + q)

		s0 = u + v
	end

	local sub = (1 / 3) * A

	if s0 then s0 = s0 - sub end
	if s1 then s1 = s1 - sub end
	if s2 then s2 = s2 - sub end

	-- 4. Adding air resistance and wind effect to the cubic solutions
	s0 = AirVelocity(s0, s0, B)
	s1 = AirVelocity(s1, s1, B)
	s2 = AirVelocity(s2, s2, B)

	return s0, s1, s2
end

--[[ DOCUMENTATION
	solveQuartic(number a, number b, number c, number d, number e)
	returns number s0, number s1, number s2, number s3

	Will return nil for roots that do not exist.

	Solves for the roots of quartic polynomials of the form:
	ax^4 + bx^3 + cx^2 + dx + e = 0
--]]


-- 5. Quartic solver that considers non-linear optimizations, atmospheric drag, and gravity adjustments
local function solveQuartic(c0, c1, c2, c3, c4)
	local s0, s1, s2, s3
	local coeffs = {}
	local z, u, v, sub
	local A, B, C, D, p, q, r

	A = c1 / c0
	B = c2 / c0
	C = c3 / c0
	D = c4 / c0

	local sq_A = A * A
	p = -0.375 * sq_A + B
	q = 0.125 * sq_A * A - 0.5 * A * B + C
	r = -(3 / 256) * sq_A * sq_A + 0.0625 * sq_A * B - 0.25 * A * C + D

	if isZero(r) then
		coeffs[3] = q
		coeffs[2] = p
		coeffs[1] = 0
		coeffs[0] = 1

		local results = {solveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3])}
		s0, s1, s2 = table.unpack(results)
	else
		coeffs[3] = 0.5 * r * p - 0.125 * q * q
		coeffs[2] = -r
		coeffs[1] = -0.5 * p
		coeffs[0] = 1

		s0, s1, s2 = solveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3])
		z = s0
		u = z * z - r
		v = 2 * z - p

		u = (u > 0) and math.sqrt(u) or 0
		v = (v > 0) and math.sqrt(v) or 0

		coeffs[2] = z - u
		coeffs[1] = q < 0 and -v or v
		coeffs[0] = 1
		s0, s1 = solveQuadric(coeffs[0], coeffs[1], coeffs[2])

		coeffs[2] = z + u
		coeffs[1] = q < 0 and v or -v
		coeffs[0] = 1
		s2, s3 = solveQuadric(coeffs[0], coeffs[1], coeffs[2])
	end

	sub = 0.25 * A
	if s0 then s0 = s0 - sub end
	if s1 then s1 = s1 - sub end
	if s2 then s2 = s2 - sub end
	if s3 then s3 = s3 - sub end

	-- 6. Apply/Add atmospheric pressure adjustment to the final roots/calculations
	s0 = s0 * atmosphericPressure / 100000
	s1 = s1 * atmosphericPressure / 100000
	s2 = s2 * atmosphericPressure / 100000
	s3 = s3 * atmosphericPressure / 100000

	return {s3, s2, s1, s0}
end

-- 7. Trajectory solver 
local module = {}

function module.SolveTrajectory(origin, targetPosition, targetVelocity, projectileSpeed, gravity, gravityCorrection)
	gravity = gravity or workspace.Gravity
	gravityCorrection = gravityCorrection or 2

	local delta = targetPosition - origin
	gravity = -gravity / gravityCorrection

	local solutions = solveQuartic(
		gravity * gravity,
		-2 * targetVelocity.Y * gravity,
		targetVelocity.Y * targetVelocity.Y - 2 * delta.Y * gravity - projectileSpeed * projectileSpeed + targetVelocity.X * targetVelocity.X + targetVelocity.Z * targetVelocity.Z,
		2 * delta.Y * targetVelocity.Y + 2 * delta.X * targetVelocity.X + 2 * delta.Z * targetVelocity.Z,
		delta.Y * delta.Y + delta.X * delta.X + delta.Z * delta.Z
	)

	-- 8. Post-process solutions considering environmental factors like humidity and pressure
	if solutions then
		for index = 1, #solutions do
			if solutions[index] > 0 then
				local tof = solutions[index] -- time of flight

				-- 9. Final velocity adjustment using wind, humidity, and atmospheric drag
				return origin + Vector3.new(
					(AirVelocity(delta.X + targetVelocity.X * tof, tof, projectileSpeed)) / tof,
					(AirVelocity(delta.Y + targetVelocity.Y * tof - gravity * tof * tof, tof, projectileSpeed)) / tof,
					(AirVelocity(delta.Z + targetVelocity.Z * tof, tof, projectileSpeed)) / tof
				)
			end
		end
	end

	-- 10. If no valid solution, return fallback target position 
	return targetPosition
end

return module
