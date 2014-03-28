package com.plantronics.device.info;

/**
 * Created by mdavis on 3/11/14.
 */
public class EulerAngles {

	public double x;
	public double y;
	public double z;

	public EulerAngles(double x_, double y_, double z_) {
		x = x_;
		y = y_;
		z = z_;
	}

	public EulerAngles(Quaternion quaternion) {
		double q0 = quaternion.w;
		double q1 = quaternion.x;
		double q2 = quaternion.y;
		double q3 = quaternion.z;

		double m22 = 2*Math.pow(q0, 2) + 2*Math.pow(q2, 2) - 1;
		double m21 = 2*q1*q2 - 2*q0*q3;
		double m13 = 2*q1*q3 - 2*q0*q2;
		double m23 = 2*q2*q3 + 2*q0*q1;
		double m33 = 2*Math.pow(q0, 2) + 2*Math.pow(q3, 2) - 1;

		double psi = -r2d(Math.atan2(m21, m22));
		double theta = r2d(Math.asin(m23));
		double phi = -r2d(Math.atan2(m13, m33));

		x = psi;
		y = theta;
		z = phi;
	}

	@Override
	public String toString() {
		return "{ " + x + ", " + y + ", " + z + " }";
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
