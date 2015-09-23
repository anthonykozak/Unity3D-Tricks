/**
	@author : Anthony KOZAK :: exoa.fr
	@description : Add your domain to the NSAppTransportSecurity for ios 9 in Unity
		Add it automatically or manually from a custom editor menu.
**/
using System;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.IO;

public class NSAppTransportSecurity
{
	[MenuItem("Exoa/Build/Add NSAppTransportSecurity")]
	private static void AddNSAppTransportSecurity()
	{
		string domain = "yourdomain.com";
		string filepath = Application.dataPath.Replace("/Assets", "/") + "_BUILDS/ios/build/Info.plist";

		if (File.Exists(filepath))
		{
			StreamReader streamReader = new StreamReader(filepath);
			string text = streamReader.ReadToEnd();
			streamReader.Close();
			if (text.IndexOf("NSAppTransportSecurity") < 1)
			{
				text = text.Replace("<key>CFBundleDevelopmentRegion</key>", "<key>NSAppTransportSecurity</key>\n<dict>\n<key>NSExceptionDomains</key>\n<dict>\n<key>" + domain + "</key>\n<dict>\n<key>NSIncludesSubdomains</key>\n<true/>\n<key>NSExceptionAllowsInsecureHTTPLoads</key>\n<true/>\n<key>NSExceptionRequiresForwardSecrecy</key>\n<true/>\n<key>NSExceptionMinimumTLSVersion</key>\n<string>TLSv1.2</string>\n<key>NSThirdPartyExceptionAllowsInsecureHTTPLoads</key>\n<true/>\n<key>NSThirdPartyExceptionRequiresForwardSecrecy</key>\n<true/>\n<key>NSThirdPartyExceptionMinimumTLSVersion</key>\n<string>TLSv1.2</string>\n<key>NSRequiresCertificateTransparency</key>\n<false/>\n</dict>\n</dict>\n</dict>\n<key>CFBundleDevelopmentRegion</key>");
				File.WriteAllText(filepath, text);
				Debug.Log("NSAppTransportSecurity Added for domain " + domain);
			}

		}
	}

	[PostProcessBuild(1080)]
	public static void OnPostProcessBuild(BuildTarget target, string path)
	{
		print("OnPostProcessBuild " + target + " " + path);
		AddNSAppTransportSecurity();
    }
}