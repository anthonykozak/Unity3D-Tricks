using UnityEditor;
using UnityEngine;
using System.Diagnostics;
using System.Collections.Generic;

public class AndroidBuildAndRun 
{
	private static string[] allScenes;
	private static string currentScene;

	[MenuItem("Exoa/Build/Android")]
	public static void PerformBuildAndroid()
	{
		GatherSceneInfo();
		string fullPath = Application.dataPath.Replace("/Assets", "/") + "_BUILDS/android/build.apk";

		// Build Game
		BuildPipeline.BuildPlayer(allScenes, fullPath, BuildTarget.StandaloneWindows, BuildOptions.None);
	}

	[MenuItem("Exoa/Build/Install build on Android")]
	public static void InstallAndroid()
	{
		// Run the game (Process class from System.Diagnostics).
		string fullPath = Application.dataPath.Replace("/Assets", "/") + "_BUILDS/android/build.apk";
		Process proc = new System.Diagnostics.Process();
		proc.StartInfo.FileName = "D:/SDK/android/sdk/platform-tools/adb.exe"; // replace with your adb exe path
		proc.StartInfo.Arguments = "-d install -r " + fullPath;
		proc.Start();
	}


	[MenuItem("Exoa/Build/Launch on Android")]
	public static void LaunchAndroid()
	{
		// Run the game (Process class from System.Diagnostics).
		string fullPath = Application.dataPath.Replace("/Assets", "/") + "_BUILDS/android/build.apk";
		string appid = PlayerSettings.bundleIdentifier;
		Process proc = new System.Diagnostics.Process();
		proc.StartInfo.FileName = "D:/SDK/android/sdk/platform-tools/adb.exe"; // replace with your adb exe path
		proc.StartInfo.Arguments = "shell am start -n " + appid + "/com.unity3d.player.UnityPlayerNativeActivity"; 
		proc.Start();
	}



	private static void GatherSceneInfo()
	{
		currentScene = EditorApplication.currentScene;
		IncrementVersion();
		List<string> list = new List<string>();
		EditorBuildSettingsScene[] scenes = EditorBuildSettings.scenes;

		for (int iLevels = 0; iLevels < scenes.Length; iLevels++)
		{
			EditorBuildSettingsScene scene = scenes[iLevels];
			if (true == scene.enabled)
			{
				list.Add(scene.path);
			}
		}
		allScenes = list.ToArray();
	}
}