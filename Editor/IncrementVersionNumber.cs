/**
	@author : Anthony KOZAK :: exoa.fr
	@description : Increment your game version number in Unity
		Launched automatically at each build process or manually from a custom editor menu.
**/
using System;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.IO;

public class IncrementVersionNumber
{
	[MenuItem("Exoa/Build/Increment version")]
	public static void IncrementVersion()
	{
		string version = PlayerSettings.bundleVersion;
		string[] parts = version.Split('.');
		int lastNum = int.Parse(parts[parts.Length - 1]);
		lastNum++;
		string newVersion = "";
		for (int i = 0; i < parts.Length - 1; i++)
			newVersion += parts[i] + ".";
		newVersion += lastNum;
		int newVersionCode = int.Parse(newVersion.Replace(".", ""));
		Debug.Log("IncrementVersion " + version + " " + newVersion + " " + newVersionCode);
		PlayerSettings.bundleVersion = newVersion;
		PlayerSettings.Android.bundleVersionCode = newVersionCode;
	}

	[PostProcessBuild(1080)]
	public static void OnPostProcessBuild(BuildTarget target, string path)
	{
		print("OnPostProcessBuild " + target + " " + path);
		IncrementVersion();
    }
}