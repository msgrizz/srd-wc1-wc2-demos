package com.plantronics.PLTDevice.info;

import java.util.Date;

/**
 * Created by mdavis on 1/16/14.
 */
public class OrientationTrackingInfo extends com.plantronics.PLTDevice.info.Info
{
	private Quaternion _rawQuaternion;

	public OrientationTrackingInfo(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration, Quaternion rawQuaternion)
	{
		super(requestType, timestamp, calibration);
//		_requestType = requestType;
//		_timestamp = timestamp;
//		_calibration = calibration;
		_rawQuaternion = rawQuaternion;
	}

	public OrientationTrackingInfo(int requestType, Date timestamp, com.plantronics.PLTDevice.calibration.Calibration calibration, EulerAngles eulerAngles)
	{
		super(requestType, timestamp, calibration);
//		_requestType = requestType;
//		_timestamp = timestamp;
//		_calibration = calibration;
		_rawQuaternion = Quaternion.QuaternionFromEulerAngles(eulerAngles);
	}

	@Override
	public String toString()
	{
		return "";
	}

	public static double d2r(double d)
	{
		return d * (Math.PI/180.0);
	}

	public static double r2d(double d)
	{
		return d * (180.0/Math.PI);
	}

	public Quaternion MultipliedQuaternions(Quaternion q, Quaternion p)
	{
		double quatmat[][] =
				{   { p.w, -p.x, -p.y, -p.z },
						{ p.x, p.w, -p.z, p.y },
						{ p.y, p.z, p.w, -p.x },
						{ p.z, -p.y, p.x, p.w },
				};

		double[] mulQuat = new double[4];
		for (int i = 0; i < 4; i++) {
			for (int j = 0; j < 4; j++) {
				double[] qq = { q.w, q.x, q.y, q.z };
				mulQuat[i] += quatmat[i][j] * qq[j];
			}
		}

		return new Quaternion(mulQuat[0], mulQuat[1], mulQuat[2], mulQuat[3]);
	}

	public Quaternion InverseQuaternion(Quaternion q)
	{
		return new Quaternion(q.w, -q.x, -q.y, -q.z);
	}

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

		@Override
		public String toString() {
			return "{ " + w + ", " + x + ", " + y + ", " + z + " }";
		}
	}

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
	}

	//	public EulerAngles getEulerAngles()
//	{
//		Quaternion quaternion = getQuaternion();
//		return EulerAngles.EulerAnglesFromQuaternion(quaternion);
//	}
//
//	public EulerAngles getRawEulerAngles()
//	{
//		return EulerAngles.EulerAnglesFromQuaternion(_rawQuaternion);
//	}
//
//	public Quaternion getQuaternion()
//	{
//		// apply cal
//		OrientationTrackingCalibration calibration = (OrientationTrackingCalibration)_calibration;
//		Quaternion inverseReferenceQuaternion = InverseQuaternion(calibration.getReferenceQuaternion());
//		Quaternion calibratedQuaternion = MultipliedQuaternions(_rawQuaternion, inverseReferenceQuaternion);
//		return calibratedQuaternion;
//	}
//
//	public Quaternion getRawQuaternion()
//	{
//		return _rawQuaternion;
//	}
//
//	private static Quaternion MultipliedQuaternions(Quaternion q, Quaternion p)
//	{
//		//double *mulQuat = malloc(sizeof(double)*4);
//		//memset(mulQuat, 0, sizeof(double)*4);
//
//		double quatmat[][] = new double[][]
//		{   { p.getW(), -p.getX(), -p.getY(), -p.getZ() },
//			{ p.getX(), p.getW(), -p.getZ(), p.getY() },
//			{ p.getY(), p.getZ(), p.getW(), -p.getX() },
//			{ p.getZ(), -p.getY(), p.getX(), p.getW() },
//		};
//
//		double[] mulQuat = new double[4];
//		double[] qq = new double[] { q.getW(), q.getX(), q.getY(), q.getZ() };
//
//		for (int i = 0; i < 4; i++) {
//			for (int j = 0; j < 4; j++) {
//				//double *qq = (double *)&q;
//				mulQuat[i] += quatmat[i][j] * qq[j];
//				//mulQuat[i] = mulQuat[i] + (quatmat[i][j] * qq[j]);
//			}
//		}
//
//		//return (PLTQuaternion){ mulQuat[0], mulQuat[1], mulQuat[2], mulQuat[3] };
//		return new Quaternion(mulQuat[0], mulQuat[1], mulQuat[2], mulQuat[3]);
//	}
//
//	private static Quaternion InverseQuaternion(Quaternion q)
//	{
//		return new Quaternion(q.getW(), -q.getX(), -q.getY(), -q.getZ());
//	}
}
