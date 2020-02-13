[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
Add-Type -AssemblyName System.Web -IgnoreWarnings

$app = '{6D809377-6AF0-444B-8957-A3773F02200E}\Rainmeter\Rainmeter.exe'

$notify = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app)

$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument

$appLogoOverrideVar = [System.Web.HttpUtility]::HtmlEncode($RmAPI.VariableStr("NotificationIcon"))
$isBigSize = $RmAPI.Variable("Big") -eq 1
$isSilent = $RmAPI.Variable("Silent") -eq 1
function EncodeVar {
	param([string]$name)
    $variableValue = $RmAPI.MeasureStr($name)

	If (($null -eq $variableValue) -Or ($variableValue -eq "")) {
		return $null
	}

	$RmAPI.Log("$variableValue")
	return [System.Web.HttpUtility]::HtmlEncode($variableValue)

}

function ToastIt {
	#Don't matter if empty
	$TitleVar = EncodeVar('NotificationTitle')
	$ContextVar = EncodeVar('NotificationContext')
	$HeroImageVar = EncodeVar('NotificationTopImage')

	$size = $(if ($isBigSize) {
	@"
	<image placement="hero" src="$HeroImageVar"/>
	<image placement="appLogoOverride" hint-crop="circle" src="$appLogoOverrideVar"/>
"@
	} else {
	@"
	<image placement="appLogoOverride" hint-crop="circle" src="$HeroImageVar"/>
"@
	})
	
	$silent = $(if ($isSilent) {
	@"
	<audio silent="true"/>
"@
	} else {
	@"
	<audio silent="false"/>
"@
	})

    $RmAPI.log($size)
[xml]$ToastTemplate = @"
<toast launch="app-defined-string">
	<visual>
		<binding template="ToastGeneric">
			<text>$TitleVar</text>
			<text>$ContextVar</text>
			$size
		</binding>
	</visual>
	$silent
</toast>
"@

$ToastXml.LoadXml($ToastTemplate.OuterXml)
$notify.Show($ToastXml)
}

function Activate-ShowInActionCenter {Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\{6D809377-6AF0-444B-8957-A3773F02200E}\Rainmeter\Rainmeter.exe" -Name "ShowInActionCenter" -Value "1"}

function Deactivate-ShowInActionCenter {Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\{6D809377-6AF0-444B-8957-A3773F02200E}\Rainmeter\Rainmeter.exe" -Name "ShowInActionCenter" -Value "0"}

