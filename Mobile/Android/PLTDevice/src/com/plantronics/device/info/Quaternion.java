package com.plantronics.device.info;

/**
 * Created by mdavis on 3/11/14.
 */

public class Quaternion {

	public double w;
	public double x;
	public double y;
	public double z;

	public Quaternion(double w_, double x_, double y_, double z_) {
		w = w_;
		x = x_;
		y = y_;
		z = z_;
	}

	public Quaternion(EulerAngles eulerAngles) {
		double psi = d2r(eulerAngles.x);
		double theta = d2r(eulerAngles.y);
		double phi = d2r(eulerAngles.z);

		double q0 = Math.cos(psi / 2.0)*Math.cos(theta / 2.0)*Math.cos(phi / 2.0)-Math.sin(psi / 2.0)*Math.sin(theta / 2.0)*Math.sin(phi / 2.0);
		double q1 = Math.cos(psi / 2.0)*Math.sin(theta / 2.0)*Math.cos(phi / 2.0)-Math.sin(psi / 2.0)*Math.cos(theta / 2.0)*Math.sin(phi / 2.0);
		double q2 = Math.cos(psi / 2.0)*Math.cos(theta / 2.0)*Math.sin(phi / 2.0)+Math.sin(psi / 2.0)*Math.sin(theta / 2.0)*Math.cos(phi / 2.0);
		double q3 = Math.sin(psi / 2.0)*Math.cos(theta / 2.0)*Math.cos(phi / 2.0)+Math.cos(psi / 2.0)*Math.sin(theta / 2.0)*Math.sin(phi / 2.0);

		w = q0;
		x = q1;
		y = q2;
		z = q3;
	}

	public Quaternion getInverse() {
		return new Quaternion(this.w, -this.x, -this.y, -this.z);
	}

	public Quaternion getMultiplied(Quaternion p) {
		double quatmat[][] =
				{   { p.w, -p.x, -p.y, -p.z },
						{ p.x, p.w, -p.z, p.y },
						{ p.y, p.z, p.w, -p.x },
						{ p.z, -p.y, p.x, p.w },
				};

		double[] mulQuat = new double[4];
		for (int i = 0; i < 4; i++) {
			for (int j = 0; j < 4; j++) {
				double[] qq = { this.w, this.x, this.y, this.z };
				mulQuat[i] += quatmat[i][j] * qq[j];
			}
		}

		return new Quaternion(mulQuat[0], mulQuat[1], mulQuat[2], mulQuat[3]);
	}

	@Override
	public String toString() {
		return "{ " + w + ", " + x + ", " + y + ", " + z + " }";
	}

	private static double d2r(double d) {
		return d * (Math.PI/180.0);
	}

	private static double r2d(double d) {
		return d * (180.0/Math.PI);
	}
}