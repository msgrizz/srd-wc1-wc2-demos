package com.plantronics.appcore.service.bluetooth.utilities;

import java.util.LinkedList;
import java.util.List;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.util.Log;

import com.plantronics.appcore.service.bluetooth.utilities.beans.DeviceInfoBean;
import com.plantronics.appcore.service.bluetooth.utilities.log.LogTag;

public class PlantronicsDeviceResolver {

	private static final String TAG = LogTag.getBluetoothPackageTagPrefix() + PlantronicsDeviceResolver.class.getSimpleName();
	
	// Headset full names
	public static final String M155_FULL_NAME = "Marque";
	public static final String VOYAGER_PRO_FULL_NAME = "Voyager PRO";
	public static final String VOYAGER_UC_PLUS_FULL_NAME = "Voyager PRO UC+";
	public static final String VOYAGER_UC_V2_FULL_NAME = "Voyager PRO UC v2";
	public static final String VOYAGER_LEGEND_FULL_NAME = "Voyager Legend";

	// static Map<String,String> friendlyToFullNameMap;

	static List<DeviceInfoBean> sDeviceInfoList;

	// added extra rows to support primary headsets that may have more than one friendly
	// name (incl. Marque 2, Voyager Legend). Also added PLT_BB903 which was missing from original list)
	static {

		// PlantronicsDeviceResolver.friendlyToFullNameMap = new HashMap<String, String>();
		// //Populate with primary devices and their full names
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PLT_M155", "Marque");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PLT_M165", "Marque 2");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PLT_A170", "Marque 2");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PLT_VoyagerPRO", "Voyager PRO");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("Voyager PRO UC v2", "Voyager PRO");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PROPlantronics", "Voyager PRO");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("Voyager PRO+", "Voyager PRO");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PLT_M1100", "Savor M1100");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PLT_BBTGO", "BackBeat GO");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PLT_BB903+", "BackBeat 903+");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PLT_BB903", "BackBeat 903");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PLT_M25-M29", "M25");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PLT_M55", "M55");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PLT_M50", "M50");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("PLT_Legend", "Voyager Legend");
		// PlantronicsDeviceResolver.friendlyToFullNameMap.put("Moorea8670", "Voyager Legend");

		PlantronicsDeviceResolver.sDeviceInfoList = new LinkedList<DeviceInfoBean>();
		// Add known devices beans in form (Friendly name reported by android / Full name / is SCO only / is A2DP only)
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PLT_M155", "Marque", false, false).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PLT_M165", "Marque 2", false, false).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PLT_A170", "Marque 2", false, false).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PLT_VoyagerPRO", "Voyager PRO", false, true).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PROPlantronics", "Voyager PRO", false, true).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("Voyager PRO UC v2", "Voyager PRO UC v2", false, true).setSupportsXevent(false));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("Voyager PRO+", "Voyager PRO UC+", false, true).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PLT_M1100", "Savor M1100", false, false).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PLT_BBTGO", "BackBeat GO", false, false).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PLT_BB903+", "BackBeat 903+", false, false).setSupportsXevent(false));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PLT_BB903", "BackBeat 903", false, false).setSupportsXevent(false));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PLT_M25-M29", "M25", false, false).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PLT_M55", "M55", false, false).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PLT_M50", "M50", false, false).setSupportsXevent(false));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("PLT_Legend", "Voyager Legend", false, true).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("Moorea8670", "Voyager Legend", false, true).setSupportsXevent(true));

		// Blackwires
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("Blackwire C720-M", "Blackwire C720", false, false).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("Blackwire C720", "Blackwire C720", false, false).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("Blackwire C710-M", "Blackwire C710", false, false).setSupportsXevent(true));
		PlantronicsDeviceResolver.sDeviceInfoList.add(new DeviceInfoBean("Blackwire C710", "Blackwire C710", false, false).setSupportsXevent(true));
	}

	/**
	 * Was the device manufactured by Plantronics? We determine this by checking the device address (BD_ADDR). Plantronics devices' addresses are in these ranges:
	 * <ul>
	 * <li>00:23:7F</li>
	 * <li>48:C1:AC</li>
	 * <li>00:03:89</li>
	 * <li>00:19:7F</li>
	 * </ul>
	 * You must update this method if we add new address ranges.
	 * <p>
	 * As a special case, BackBeat 903+ headsets appear to have addresses in several non-Plantronics address ranges (00:1C:EF, F0:65:DD, others?), 
	 * with friendly names starting with "PLT_BB903".
	 * </p>
	 * 
	 * @param device
	 *            the Bluetooth device in question
	 * @return true if its address belongs to one of the ranges Plantronics controls, or otherwise resembles a Plantronics device (see note about BB903+ above).
	 */
	public static boolean isPlantronicsDevice(BluetoothDevice device) {

		// General case
		final String addr = device.getAddress();
		if (addr.startsWith("00:23:7F") || addr.startsWith("48:C1:AC") || addr.startsWith("00:03:89") || addr.startsWith("00:19:7F")) {
			return true;
		}

		// BackBeat 903/903+ special case
		final String name = device.getName();
		return name != null && name.startsWith("PLT_BB903");
	}

	public static boolean doesSupportXEvents(BluetoothDevice bluetoothDevice) {
		if (bluetoothDevice == null)
			return false;
		for (DeviceInfoBean deviceInfoBean : sDeviceInfoList) {
			if (deviceInfoBean.getFriendlyName().equalsIgnoreCase(bluetoothDevice.getName())) {
				return deviceInfoBean.doesSupportXevents();
			}
		}
		return false;
	}

	public static boolean isPlantronicsPrimaryDevice(BluetoothDevice bluetoothDevice) {
		for (DeviceInfoBean deviceInfoBean : sDeviceInfoList) {
			if (deviceInfoBean.getFriendlyName().equalsIgnoreCase(bluetoothDevice.getName())) {
				return true;
			}
		}
		return false;
	}

	public static String getFullName(BluetoothDevice bluetoothDevice) {
		if (bluetoothDevice.getName() == null) {
			return bluetoothDevice.getAddress();
		}
		String friendlyName = bluetoothDevice.getName();
		String fullName = null;
		for (DeviceInfoBean deviceInfoBean : sDeviceInfoList) {
			if (deviceInfoBean.getFriendlyName().equalsIgnoreCase(bluetoothDevice.getName())) {
				fullName = deviceInfoBean.getFullName();
			}
		}
		if (fullName == null) {
			return friendlyName;
		}
		return fullName;
	}

	public static boolean isEqualToConnectedDevice(BluetoothDevice device, BluetoothDevice connectedDevice) {
		return connectedDevice != null && device != null && device.getAddress().equals(connectedDevice.getAddress());
	}

	public static boolean isDeviceA2DPOnlyConstrained(BluetoothDevice bluetoothDevice) {
		if (bluetoothDevice == null)
			return false;
		for (DeviceInfoBean deviceInfoBean : sDeviceInfoList) {
			if (deviceInfoBean.getFriendlyName().equalsIgnoreCase(bluetoothDevice.getName())) {
				return deviceInfoBean.isA2dpOnly();
			}
		}
		return false;
	}

	public static boolean isDeviceSupportedOnAndroidApi13(String bluetoothAddress) {
		if (bluetoothAddress == null) {
			Log.w(TAG, "Bluetooth address is null.");
			return false;
		}

		BluetoothDevice bluetoothDevice = BluetoothAdapter.getDefaultAdapter().getRemoteDevice(bluetoothAddress);
		return isDeviceSupportedOnAndroidApi13(bluetoothDevice);
	}

	public static boolean isDeviceSupportedOnAndroidApi13(BluetoothDevice device) {
		if (device == null) {
			Log.w(TAG, "Bluetooth device is null.");
			return false;
		}

		String deviceName = device.getName();
		if (HeadsetsNotSupportedOnAndroidApi13.PLT_LEGEND.equalsIgnoreCase(deviceName) || HeadsetsNotSupportedOnAndroidApi13.MOOREA_8670.equalsIgnoreCase(deviceName)) {
			return false;
		}
		return true;
	}

	public class HeadsetsNotSupportedOnAndroidApi13 {
		public static final String PLT_LEGEND = "PLT_Legend";
		public static final String MOOREA_8670 = "Moorea8670";
	}

}
