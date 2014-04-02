package com.plantronics.device.info;

/**
 * Created by mdavis on 3/11/14.
 */

public class Quaternion {

	private double 	_w;
	private double 	_x;
	private double 	_y;
	private double 	_z;


	public Quaternion(double w, double x, double y, double z) {
		_w = w;
		_x = x;
		_y = y;
		_z = z;
	}

	public Quaternion(EulerAngles eulerAngles) {
		double psi = d2r(eulerAngles.getX());
		double theta = d2r(eulerAngles.getY());
		double phi = d2r(eulerAngles.getZ());

		double q0 = Math.cos(psi / 2.0)*Math.cos(theta / 2.0)*Math.cos(phi / 2.0)-Math.sin(psi / 2.0)*Math.sin(theta / 2.0)*Math.sin(phi / 2.0);
		double q1 = Math.cos(psi / 2.0)*Math.sin(theta / 2.0)*Math.cos(phi / 2.0)-Math.sin(psi / 2.0)*Math.cos(theta / 2.0)*Math.sin(phi / 2.0);
		double q2 = Math.cos(psi / 2.0)*Math.cos(theta / 2.0)*Math.sin(phi / 2.0)+Math.sin(psi / 2.0)*Math.sin(theta / 2.0)*Math.cos(phi / 2.0);
		double q3 = Math.sin(psi / 2.0)*Math.cos(theta / 2.0)*Math.cos(phi / 2.0)+Math.cos(psi / 2.0)*Math.sin(theta / 2.0)*Math.sin(phi / 2.0);

		_w = q0;
		_x = q1;
		_y = q2;
		_z = q3;
	}

	public Quaternion getInverse() {
		return new Quaternion(_w, -_x, -_y, -_z);
	}

	public Quaternion getMultiplied(Quaternion p) {
		double quatmat[][] =
				{   { p._w, -p._x, -p._y, -p._z },
						{ p._x, p._w, -p._z, p._y },
						{ p._y, p._z, p._w, -p._x },
						{ p._z, -p._y, p._x, p._w },
				};

		double[] mulQuat = new double[4];
		for (int i = 0; i < 4; i++) {
			for (int j = 0; j < 4; j++) {
				double[] qq = { _w, _x, _y, _z };
				mulQuat[i] += quatmat[i][j] * qq[j];
			}
		}

		return new Quaternion(mulQuat[0], mulQuat[1], mulQuat[2], mulQuat[3]);
	}

	public double getW() {
		return _w;
	}

	public double getX() {
		return _x;
	}

	public double getY() {
		return _y;
	}

	public double getZ() {
		return _z;
	}

	@Override
	public String toString() {
		return "{ " + _w + ", " + _x + ", " + _y + ", " + _z + " }";
	}

	private static double d2r(double d) {
		return d * (Math.PI/180.0);
	}

	private static double r2d(double d) {
		return d * (180.0/Math.PI);
	}
}