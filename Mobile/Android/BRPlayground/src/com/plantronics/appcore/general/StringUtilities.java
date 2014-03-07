/*
 * Copyright 2012 Plantronics, Inc.  All rights reserved.
 * This code is confidential and proprietary information belonging
 * to Plantronics, Inc. and may not be copied, modified or distributed
 * without the express written consent of Plantronics, Inc.
 */
package com.plantronics.appcore.general;


public class StringUtilities {
	/**
	 * Conversion of unicode value to a String
	 * @param unicodeValue
	 * 		int unicode value
	 */
	public static String fromUnicodeValueToString(int unicodeValue) {		
		 int[] codePoints ={unicodeValue};
	     String s= new String(codePoints,0,1);
		return s; 
	}
	
	public static boolean isEmpty(String s) {
		return s == null || s.trim().length() == 0;				
	}
}
