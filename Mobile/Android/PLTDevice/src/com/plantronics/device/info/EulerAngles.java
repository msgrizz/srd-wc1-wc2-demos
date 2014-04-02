package com.plantronics.device.info;

/**
 * Created by mdavis on 3/11/14.
 */
public class EulerAngles {

	private double 	_x;
	private double 	_y;
	private double 	_z;


	public EulerAngles(double x, double y, double z) {
		_x = x;
		_y = y;
		_z = z;
	}

	public EulerAngles(Quaternion quaternion) {
		double q0 = quaternion.getW();
		double q1 = quaternion.getX();
		double q2 = quaternion.getY();
		double q3 = quaternion.getZ();

		double m22 = 2*Math.pow(q0, 2) + 2*Math.pow(q2, 2) - 1;
		double m21 = 2*q1*q2 - 2*q0*q3;
		double m13 = 2*q1*q3 - 2*q0*q2;
		double m23 = 2*q2*q3 + 2*q0*q1;
		double m33 = 2*Math.pow(q0, 2) + 2*Math.pow(q3, 2) - 1;

		double psi = -r2d(Math.atan2(m21, m22));
		double theta = r2d(Math.asin(m23));
		double phi = -r2d(Math.atan2(m13, m33));

		_x = psi;
		_y = theta;
		_z = phi;
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
		return "{ " + _x + ", " + _y + ", " + _z + " }";
	}

	private static double d2r(double d)
	{
		return d * (Math.PI/180.0);
	}

	private static double r2d(double d)
	{
		return d * (180.0/Math.PI);
	}
}
