using UnityEditor;
using UnityEngine;
using System.Diagnostics;
using System.Collections.Generic;

public class BuildAndRun 
{
	private static string[] allScenes;

	[MenuItem("Exoa/Build/Build And Run Exe %&b")]
	public static void BuildGame()
	{
		GatherSceneInfo();
		// Get filename.
		string fullPath = Application.dataPath.Replace("/Assets", "/") + "_BUILDS/win/build.exe";
		
		// Build player.
		BuildPipeline.BuildPlayer(allScenes, fullPath, BuildTarget.StandaloneWindows, BuildOptions.None);
		RunGame();
	}
	[MenuItem("Exoa/Build/Run Exe %&r")]
	public static void RunGame()
	{
		string fullPath = Application.dataPath.Replace("/Assets", "/") + "_BUILDS/win/build.exe";
		
		// Run the game (Process class from System.Diagnostics).
		Process proc = new Process();
		proc.StartInfo.FileName = fullPath;
		proc.Start();
	}


	private static void GatherSceneInfo()
	{
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
		UnityEngine.Debug.Log(allScenes);
	}
}