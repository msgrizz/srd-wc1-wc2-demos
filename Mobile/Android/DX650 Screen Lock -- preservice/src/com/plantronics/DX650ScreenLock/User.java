/* ********************************************************************************************************
	User.java
	com.plantronics.DX650ScreenLock

	Created by mdavis on 06/04/2013.
	Copyright (c) 2013 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.DX650ScreenLock;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

public class User implements java.io.Serializable {

	private String username = null;
	private String passphrase = null;

	/* ****************************************************************************************************
			User
	*******************************************************************************************************/

	public User() {}

	public User(String aUsername, String aPassphrase) {
		username = aUsername;
		passphrase = aPassphrase;
	}

	/* ****************************************************************************************************
			Object
	*******************************************************************************************************/

	@Override
	public String toString() {
		return String.format("Username: %s\t\tPassphrase: %s",username,passphrase);
	}

	/* ****************************************************************************************************
			Public
	*******************************************************************************************************/

	public String getUsername() {
		return username;
	}

	public String getPassphrase() {
		return passphrase;
	}

	/* ****************************************************************************************************
			Serializable
	*******************************************************************************************************/

	private void writeObject(ObjectOutputStream out) throws IOException {
		out.writeObject(username);
		out.writeObject(passphrase);
		out.close();
	}

	private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
		username = (String)in.readObject();
		passphrase = (String)in.readObject();
		in.close();
	}
}
