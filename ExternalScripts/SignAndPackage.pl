#!/usr/bin/perl
use File::Copy;
use File::Find;
use Cwd;

# Exoa SignAndPackage script v1.1
# Author : Anthony Kozak :: exoa.fr
# Place this script in the same folder as the generated .app file from Unity
# YOU WOULD NEED IN THIS DIRECTOY:
# - a filled Info.plist file
# - a PlayerIcon.icns file
# - a filled entitlements.entitlements file
# - a UnityPlayerIcon.png file
# YOU CAN CHECK YOUR INSTALLED CERTIFICATES NAMES USING
# security find-identity -p codesigning

logit("Hello !");



my $app_found = found_app_indir();
my $appName = ask("What's the .app name in this directory ?", $app_found);
my $appPath = getcwd . "/".$appName.".app";
my $appType = ask("Is this app for the MacAppStore or External ?","MacAppStore");
my $appPathSigned = getcwd . "/".$appType."/".$appName.".app";
my $packagePath = getcwd . "/".$appType."/".$appName.".pkg";



my $profile = ask("What's the provision profile name to use in this directory ?","profile.provisionprofile");
my $doCodeSigning = ask("Sign the app ?", "true");
my $doCreatePackage = ask("Generate package ?","true");
my $copyInfopList = ask("Copy Info.plist from this directory inside the .app ?","true");
my $copyIcons = ask("Copy PlayerIcon.icns from this directory inside the .app ?","false");
my $copyIcon = ask("Copy UnityPlayerIcon.png from this directory inside the .app ?","true");

my $srcAssetPath = "/";

my $certificateApplication = ask("What's the application certificate name ?", $appType eq "MacAppStore" ? "3rd Party Mac Developer Application:" : "Developer ID Application:");
my $certificateInstaller = "";
if($doCreatePackage eq "true")
{
    $certificateInstaller = ask("What's the installer certificate name ?", $appType eq "MacAppStore" ? "3rd Party Mac Developer Installer:" : "Developer ID Installer:");
}
my $entitlementsFileName = "";
if($appType eq "MacAppStore")
{
    $entitlementsFileName = ask("What's the .entitlements file name in this directory ?", "entitlements.entitlements");
    $entitlementsFileName = "--entitlements \"".$entitlementsFileName."\"";
}

logit("*** Starting Process - Building at '$appPath' ***");


# src and dest are temp variables. Just ignore them... :-)
my $src = "";
my $dest = "";

# Creating target dir
mkdir $appType, 0755;

# this copies your own /Info.plist to the generated game
if($copyInfopList eq "true")
{
    $plist = getcwd . $srcAssetPath . "Info.plist";
    $dest = $appPath . "/Contents/Info.plist";
    print ("\n*** Copying " . getShort($plist). " to " . getShort($dest));
    copy($plist, $dest) or die "File can not be copied: " . $plist;
}
    
# this copies PlayerIcon.icns to your generated game replacing the original app icon by your own
if($copyIcons eq "true")
{
    $icons = getcwd . $srcAssetPath . "PlayerIcon.icns";
    $dest = $appPath . "/Contents/Resources/PlayerIcon.icns";
    print ("\n*** Copying " . $icons . " to " . $dest);
    copy($icons, $dest) or die "File can not be copied: " . $icons;
}
# this copies /UnityPlayerIcon.png to your generated game replacing the original Unity Player Icon by your own
if($copyIcon eq "true")
{
    $playericon = getcwd . $srcAssetPath . "UnityPlayerIcon.png";
    $dest = $appPath . "/Contents/Resources/UnityPlayerIcon.png";
    print ("\n*** Copying " . getShort($playericon) . " to " . getShort($dest));
    copy($playericon, $dest) or die "File can not be copied: " . $playericon;
}
# this copies $profile to your generated game 
$src = getcwd . $srcAssetPath . $profile;
$dest = $appPath . "/Contents/embedded.provisionprofile";
print ("\n*** Copying " . getShort($src) . " to " . getShort($dest));
copy($src, $dest) or die "File can not be copied: " . $src;

# this copies appPath to appPathSigned and use it
print ("\n*** Copying " . getShort($appPath) . " to " . getShort($appPathSigned));
system("cp -r \"".$appPath."\" \"".$appPathSigned."\"");

#fail safe check: If accidentially signing is set to false, but packaging set to true, signing is turned on to create a valid package.
if ($doCreatePackage eq "true") {
	$doCodeSigning = true;
}

## Chmod and remove unecessary files
system("/bin/chmod -R a+rwx \"$appPathSigned\"");
system("find \"$appPathSigned\" -name \*.meta -exec rm -r \"{}\" \\;");
system("/usr/sbin/chown -RH \"cestdesbullshit1:staff\" \"$appPathSigned\"");
system("/bin/chmod -RH u+w,go-w,a+rX \"$appPathSigned\"");
my $CodesignEnvironment = $ENV{'CODESIGN_ALLOCATE'};
$ENV{'CODESIGN_ALLOCATE'}="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate";


# Auto code signing
if ($doCodeSigning eq "true") {
	recursiveCodesign("$appPathSigned/Contents/Frameworks");
	recursiveCodesign("$appPathSigned/Contents/Plugins");
	recursiveCodesign("$appPathSigned/Contents/MacOS");
	logit ("*** Start signing");
	system("/usr/bin/codesign --force --timestamp=none --sign \"" . $certificateApplication . "\" ".$entitlementsFileName." \"" . $appPathSigned . "\"");
	logit ("*** Verify signing");
	system("codesign --verify --verbose \"" . $appPathSigned . "\"");
}

# Auto creating a package file?
if ($doCreatePackage eq "true") {
	logit("*** Start packaging");
	system("productbuild --component \"" . $appPathSigned . "\" /Applications --sign \"". $certificateInstaller . "\" --product \"$appPathSigned/Contents/Info.plist\" \"" . $packagePath . "\"");
}
$ENV{'CODESIGN_ALLOCATE'}=$CodesignEnvironment;
logit("*** ALL DONE ! ***");

sub ask{
    my $text = shift;
    my $default = shift;
    logit($text . " [default: ".$default."]");
    my $answer = <STDIN>;
    chomp $answer;
    return ($answer eq "") ? $default : $answer;
   
}
sub logit{
    my $text = shift;
    print("\n".$text."\n");
}
sub recursiveCodesign {

    my $dirName = shift;
    print("\n*** Recursive Codesigning ".getShort($dirName)."\n");
    opendir my($dh), $dirName or return;
    my @files = readdir($dh);
    closedir $dh;
    foreach my $currentFile (@files) {
        next if $currentFile =~ /^\.{1,2}$/;
        if ( lc($currentFile) =~ /.bundle$/ or lc($currentFile) =~ /.dylib$/ or lc($currentFile) =~ /.a$/ or lc($currentFile) =~ /.so$/ or lc($currentFile) =~ /.lib$/ or (-f "$dirName/$currentFile" && $currentFile =~ /^[^.]*$/ && `file "$dirName/$currentFile"` =~ /Mach-O/) ) {
            print("\tCodesigning ".getShort($currentFile)."\n");
            system("/usr/bin/codesign --force --timestamp=none --sign \"".$certificateApplication."\" \"$dirName/$currentFile\"");
        }
        if (-d "$dirName/$currentFile") {
             recursiveCodesign("$dirName/$currentFile");
        }
    }
}
sub found_app_indir()
{
	opendir(my $dh, '.') || die "cant open dir";
	my @list_found = grep { /.app$/ } readdir($dh);
	my $app_found = @list_found[0];
	chop($app_found); chop($app_found);chop($app_found); chop($app_found);
	return $app_found;
}
sub getShort() {
	my $subject = shift;
	my $search = getcwd . "/";
	my $replace = "";
	my $pos = index($subject, $search);
	while($pos > -1) {
		substr($subject, $pos, length($search), $replace);
		$pos = index($subject, $search, $pos + length($replace));
	}
	return $subject;
}