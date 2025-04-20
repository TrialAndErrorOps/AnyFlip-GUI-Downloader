Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

# Add custom notification class
$customNotificationXaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Notification" 
    SizeToContent="WidthAndHeight" 
    WindowStyle="None" 
    ResizeMode="NoResize" 
    AllowsTransparency="True" 
    Background="Transparent" 
    WindowStartupLocation="CenterScreen"
    ShowInTaskbar="False"
    Topmost="True"
    MaxWidth="500">
    
    <Window.Resources>
        <Style x:Key="NotificationButtonStyle" TargetType="Button">
            <Setter Property="Background" Value="#512888"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontFamily" Value="Segoe UI"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Height" Value="36"/>
            <Setter Property="Padding" Value="16,0"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="MinWidth" Value="90"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" 
                                Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                CornerRadius="2">
                            <ContentPresenter x:Name="contentPresenter" 
                                             Focusable="False" 
                                             HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" 
                                             Margin="{TemplateBinding Padding}" 
                                             RecognizesAccessKey="True" 
                                             SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}" 
                                             VerticalAlignment="{TemplateBinding VerticalContentAlignment}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="true">
                                <Setter Property="Background" Value="#3F216B" TargetName="border"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="true">
                                <Setter Property="Background" Value="#2D184D" TargetName="border"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        
        <Style x:Key="NotificationSecondaryButtonStyle" TargetType="Button" BasedOn="{StaticResource NotificationButtonStyle}">
            <Setter Property="Background" Value="#A7A8AA"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" 
                                Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                CornerRadius="2">
                            <ContentPresenter x:Name="contentPresenter" 
                                             Focusable="False" 
                                             HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" 
                                             Margin="{TemplateBinding Padding}" 
                                             RecognizesAccessKey="True" 
                                             SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}" 
                                             VerticalAlignment="{TemplateBinding VerticalContentAlignment}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="true">
                                <Setter Property="Background" Value="#888888" TargetName="border"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="true">
                                <Setter Property="Background" Value="#666666" TargetName="border"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    
    <Border CornerRadius="8" Background="White" BorderBrush="#DDDDDD" BorderThickness="1" Margin="10">
        <Border.Effect>
            <DropShadowEffect ShadowDepth="0" BlurRadius="15" Opacity="0.6" Color="Black"/>
        </Border.Effect>
        <Grid MinWidth="350">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            
            <!-- Header with icon and title -->
            <Grid Grid.Row="0">
                <Grid.Background>
                    <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                        <GradientStop Color="#512888" Offset="0.0"/>
                        <GradientStop Color="#3F216B" Offset="0.7"/>
                        <GradientStop Color="#2D184D" Offset="1.0"/>
                    </LinearGradientBrush>
                </Grid.Background>
                <Grid.Margin>
                    <Thickness Left="0" Top="0" Right="0" Bottom="0"/>
                </Grid.Margin>
                <Grid Margin="15,12">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    
                    <Border Width="32" Height="32" Background="White" CornerRadius="16" Margin="0,0,12,0" VerticalAlignment="Center">
                        <TextBlock x:Name="IconText" Text="{Binding IconText}" FontFamily="Segoe UI Symbol" 
                                   FontSize="18" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" 
                                   Foreground="{Binding IconColor}"/>
                    </Border>
                    
                    <TextBlock Grid.Column="1" Text="{Binding Title}" FontSize="18" FontWeight="SemiBold" 
                               Foreground="White" VerticalAlignment="Center"/>
                </Grid>
            </Grid>
            
            <!-- Message content -->
            <TextBlock Grid.Row="1" Text="{Binding Message}" Margin="20,15" TextWrapping="Wrap" 
                       FontSize="14" FontFamily="Segoe UI" Foreground="#333333" MaxWidth="460"/>
            
            <!-- Buttons -->
            <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="20,5,20,15">
                <Button x:Name="btnOK" Content="OK" Style="{StaticResource NotificationButtonStyle}" 
                        Visibility="{Binding OKButtonVisibility}"/>
                <Button x:Name="btnYes" Content="Yes" Style="{StaticResource NotificationButtonStyle}" 
                        Visibility="{Binding YesButtonVisibility}"/>
                <Button x:Name="btnNo" Content="No" Style="{StaticResource NotificationSecondaryButtonStyle}" 
                        Visibility="{Binding NoButtonVisibility}"/>
                <Button x:Name="btnCancel" Content="Cancel" Style="{StaticResource NotificationSecondaryButtonStyle}" 
                        Visibility="{Binding CancelButtonVisibility}"/>
            </StackPanel>
        </Grid>
    </Border>
</Window>
"@

# Define the custom notification function
function Show-CustomNotification {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$Title = "Notification",
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Information", "Success", "Warning", "Error", "Question")]
        [string]$Type = "Information",
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("OK", "YesNo", "YesNoCancel", "OKCancel")]
        [string]$Buttons = "OK"
    )
    
    try {
        # Create reader with the XAML
        $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($customNotificationXaml))
        $notificationWindow = [Windows.Markup.XamlReader]::Load($reader)
        
        # Find UI elements
        $btnOK = $notificationWindow.FindName("btnOK")
        $btnYes = $notificationWindow.FindName("btnYes")
        $btnNo = $notificationWindow.FindName("btnNo")
        $btnCancel = $notificationWindow.FindName("btnCancel")
        $iconText = $notificationWindow.FindName("IconText")
        
        # Set window properties based on notification type
        switch ($Type) {
            "Information" {
                $headerBackground = "#007ACC"  # Blue
                $iconColor = "#007ACC"
                $icon = "ℹ"
            }
            "Success" {
                $headerBackground = "#28A745"  # Green
                $iconColor = "#28A745"
                $icon = "✓"
            }
            "Warning" {
                $headerBackground = "#FFC107"  # Yellow/Orange
                $iconColor = "#FFC107"
                $icon = "⚠"
            }
            "Error" {
                $headerBackground = "#DC3545"  # Red
                $iconColor = "#DC3545"
                $icon = "✗"
            }
            "Question" {
                $headerBackground = "#512888"  # KSU Purple
                $iconColor = "#512888"
                $icon = "?"
            }
        }
        
        # Set button visibility based on button type
        $okVisibility = "Collapsed"
        $yesVisibility = "Collapsed"
        $noVisibility = "Collapsed"
        $cancelVisibility = "Collapsed"
        
        switch ($Buttons) {
            "OK" {
                $okVisibility = "Visible"
            }
            "YesNo" {
                $yesVisibility = "Visible"
                $noVisibility = "Visible"
            }
            "YesNoCancel" {
                $yesVisibility = "Visible"
                $noVisibility = "Visible"
                $cancelVisibility = "Visible"
            }
            "OKCancel" {
                $okVisibility = "Visible"
                $cancelVisibility = "Visible"
            }
        }
        
        # Create a solid color brush for the header background
        $headerBackgroundBrush = New-Object System.Windows.Media.SolidColorBrush
        $headerBackgroundBrush.Color = [System.Windows.Media.ColorConverter]::ConvertFromString($headerBackground)
        
        # Create a solid color brush for the icon color
        $iconColorBrush = New-Object System.Windows.Media.SolidColorBrush
        $iconColorBrush.Color = [System.Windows.Media.ColorConverter]::ConvertFromString($iconColor)
        
        # Set data context with all the bindings using explicit brush objects
        $notificationWindow.DataContext = [PSCustomObject]@{
            Title = $Title
            Message = $Message
            HeaderBackground = $headerBackgroundBrush
            IconText = $icon
            IconColor = $iconColorBrush
            OKButtonVisibility = $okVisibility
            YesButtonVisibility = $yesVisibility
            NoButtonVisibility = $noVisibility
            CancelButtonVisibility = $cancelVisibility
        }
        
        # Set result variable
        $script:notificationResult = $null
        
        # Add button click handlers
        if ($btnOK) {
            $btnOK.Add_Click({
                $script:notificationResult = "OK"
                $notificationWindow.Close()
            })
        }
        
        if ($btnYes) {
            $btnYes.Add_Click({
                $script:notificationResult = "Yes"
                $notificationWindow.Close()
            })
        }
        
        if ($btnNo) {
            $btnNo.Add_Click({
                $script:notificationResult = "No"
                $notificationWindow.Close()
            })
        }
        
        if ($btnCancel) {
            $btnCancel.Add_Click({
                $script:notificationResult = "Cancel"
                $notificationWindow.Close()
            })
        }
        
        # Add key press handlers for Enter/Escape
        $notificationWindow.Add_KeyDown({
            param($sender, $e)
            
            if ($e.Key -eq "Return" -or $e.Key -eq "Enter") {
                # Default action - use primary button
                if ($Buttons -eq "OK" -or $Buttons -eq "OKCancel") {
                    $script:notificationResult = "OK"
                }
                else {
                    $script:notificationResult = "Yes"
                }
                $notificationWindow.Close()
            }
            elseif ($e.Key -eq "Escape") {
                # Escape key - cancel or close
                if ($Buttons -eq "OKCancel" -or $Buttons -eq "YesNoCancel") {
                    $script:notificationResult = "Cancel"
                }
                elseif ($Buttons -eq "YesNo") {
                    $script:notificationResult = "No"
                }
                else {
                    $script:notificationResult = "OK"
                }
                $notificationWindow.Close()
            }
        })
        
        # Show the notification window as a dialog
        try {
            $null = $notificationWindow.ShowDialog()
        }
        catch {
            Write-Host "Error showing dialog: $_"
            throw
        }
        
        # Return the result - map to standard MessageBoxResult enum for compatibility
        switch ($script:notificationResult) {
            "OK" { return [System.Windows.MessageBoxResult]::OK }
            "Yes" { return [System.Windows.MessageBoxResult]::Yes }
            "No" { return [System.Windows.MessageBoxResult]::No }
            "Cancel" { return [System.Windows.MessageBoxResult]::Cancel }
            default { return [System.Windows.MessageBoxResult]::None }
        }
    }
    catch {
        Write-Host "Error showing custom notification: $_"
        # Fallback to standard MessageBox if custom notification fails
        return [System.Windows.MessageBox]::Show($Message, $Title)
    }
}

# Define the XAML UI as a string variable with explicit type
[string]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="AnyFlip Downloader" Height="720" Width="800" WindowStartupLocation="CenterScreen"
    Background="#F8F9FA" FontFamily="Segoe UI">
    
    <Window.Resources>
        <!-- Color Variables -->
        <SolidColorBrush x:Key="PrimaryColor" Color="#512888"/>
        <SolidColorBrush x:Key="PrimaryLightColor" Color="#673AB7"/>
        <SolidColorBrush x:Key="PrimaryDarkColor" Color="#3F216B"/>
        <SolidColorBrush x:Key="SecondaryColor" Color="#A7A8AA"/>
        <SolidColorBrush x:Key="TextPrimaryColor" Color="#212529"/>
        <SolidColorBrush x:Key="TextSecondaryColor" Color="#6C757D"/>
        <SolidColorBrush x:Key="BackgroundColor" Color="#F8F9FA"/>
        <SolidColorBrush x:Key="CardBackgroundColor" Color="White"/>
        <SolidColorBrush x:Key="SuccessColor" Color="#28A745"/>
        <SolidColorBrush x:Key="WarningColor" Color="#FFC107"/>
        <SolidColorBrush x:Key="ErrorColor" Color="#DC3545"/>
        
        <!-- Header Style -->
        <Style x:Key="HeaderTextBlockStyle" TargetType="TextBlock">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontFamily" Value="Segoe UI"/>
            <Setter Property="FontSize" Value="20"/>
            <Setter Property="Margin" Value="0,0,0,0"/>
            <Setter Property="TextAlignment" Value="Left"/>
        </Style>
        
        <!-- Label Style -->
        <Style x:Key="LabelTextBlockStyle" TargetType="TextBlock">
            <Setter Property="Foreground" Value="{StaticResource TextPrimaryColor}"/>
            <Setter Property="FontFamily" Value="Segoe UI"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="VerticalAlignment" Value="Center"/>
            <Setter Property="Margin" Value="0,0,0,4"/>
        </Style>
        
        <!-- Info Text Style -->
        <Style x:Key="InfoTextBlockStyle" TargetType="TextBlock">
            <Setter Property="Foreground" Value="{StaticResource TextSecondaryColor}"/>
            <Setter Property="FontFamily" Value="Segoe UI"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="TextWrapping" Value="Wrap"/>
            <Setter Property="Margin" Value="0,0,0,4"/>
            <Setter Property="Opacity" Value="0.8"/>
        </Style>
        
        <!-- Modern TextBox Style with reduced padding -->
        <Style x:Key="ModernTextBox" TargetType="TextBox">
            <Setter Property="Height" Value="32"/>
            <Setter Property="Padding" Value="4,2"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#DEE2E6"/>
            <Setter Property="Background" Value="White"/>
            <Setter Property="FontFamily" Value="Segoe UI"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Foreground" Value="{StaticResource TextPrimaryColor}"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TextBox">
                        <Border x:Name="border" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                Background="{TemplateBinding Background}" 
                                CornerRadius="4"
                                SnapsToDevicePixels="True">
                            <ScrollViewer x:Name="PART_ContentHost" Focusable="False" 
                                         HorizontalScrollBarVisibility="Hidden" 
                                         VerticalScrollBarVisibility="Hidden"
                                         Margin="{TemplateBinding Padding}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="true">
                                <Setter Property="BorderBrush" Value="{StaticResource PrimaryColor}" TargetName="border"/>
                            </Trigger>
                            <Trigger Property="IsFocused" Value="true">
                                <Setter Property="BorderBrush" Value="{StaticResource PrimaryColor}" TargetName="border"/>
                                <Setter Property="BorderThickness" Value="2" TargetName="border"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="false">
                                <Setter Property="Background" Value="#F8F9FA" TargetName="border"/>
                                <Setter Property="Opacity" Value="0.7" TargetName="border"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Primary Button Style -->
        <Style x:Key="PrimaryButton" TargetType="Button">
            <Setter Property="Background" Value="{StaticResource PrimaryColor}"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontFamily" Value="Segoe UI"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Height" Value="44"/>
            <Setter Property="Padding" Value="24,0"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" 
                                Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                CornerRadius="4">
                            <Border.Effect>
                                <DropShadowEffect ShadowDepth="1" Direction="270" BlurRadius="4" Opacity="0.2" Color="Black"/>
                            </Border.Effect>
                            <ContentPresenter x:Name="contentPresenter" 
                                             Focusable="False" 
                                             HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" 
                                             Margin="{TemplateBinding Padding}" 
                                             RecognizesAccessKey="True" 
                                             SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}" 
                                             VerticalAlignment="{TemplateBinding VerticalContentAlignment}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="true">
                                <Setter Property="Background" Value="{StaticResource PrimaryDarkColor}" TargetName="border"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="true">
                                <Setter Property="Background">
                                    <Setter.Value>
                                        <SolidColorBrush Color="#2D184D"/>
                                    </Setter.Value>
                                </Setter>
                                <Setter Property="Effect">
                                    <Setter.Value>
                                        <DropShadowEffect ShadowDepth="0" Direction="0" BlurRadius="2" Opacity="0.1" Color="Black"/>
                                    </Setter.Value>
                                </Setter>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="false">
                                <Setter Property="Background" Value="{StaticResource SecondaryColor}" TargetName="border"/>
                                <Setter Property="Opacity" Value="0.7" TargetName="border"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Secondary Button Style -->
        <Style x:Key="SecondaryButton" TargetType="Button">
            <Setter Property="Background" Value="#F8F9FA"/>
            <Setter Property="Foreground" Value="{StaticResource TextPrimaryColor}"/>
            <Setter Property="BorderBrush" Value="#DEE2E6"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontFamily" Value="Segoe UI"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Height" Value="44"/>
            <Setter Property="Padding" Value="24,0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" 
                                Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                CornerRadius="4">
                            <ContentPresenter x:Name="contentPresenter" 
                                             Focusable="False" 
                                             HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" 
                                             Margin="{TemplateBinding Padding}" 
                                             RecognizesAccessKey="True" 
                                             SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}" 
                                             VerticalAlignment="{TemplateBinding VerticalContentAlignment}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="true">
                                <Setter Property="Background" Value="#E9ECEF" TargetName="border"/>
                                <Setter Property="BorderBrush" Value="#CED4DA" TargetName="border"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="true">
                                <Setter Property="Background" Value="#DEE2E6" TargetName="border"/>
                                <Setter Property="BorderBrush" Value="#ADB5BD" TargetName="border"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Modern RichTextBox (Log) Style -->
        <Style x:Key="ModernRichTextBox" TargetType="RichTextBox">
            <Setter Property="Background" Value="White"/>
            <Setter Property="BorderBrush" Value="#DEE2E6"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12"/>
            <Setter Property="IsReadOnly" Value="True"/>
            <Setter Property="VerticalScrollBarVisibility" Value="Auto"/>
            <Setter Property="FontFamily" Value="Consolas"/>
            <Setter Property="FontSize" Value="13"/>
        </Style>
        
        <!-- Modern Progress Bar Style -->
        <Style x:Key="ModernProgressBar" TargetType="ProgressBar">
            <Setter Property="Height" Value="8"/>
            <Setter Property="Foreground" Value="{StaticResource PrimaryColor}"/>
            <Setter Property="Background" Value="#E9ECEF"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ProgressBar">
                        <Grid x:Name="TemplateRoot" SnapsToDevicePixels="true">
                            <Border Background="{TemplateBinding Background}" 
                                    BorderBrush="{TemplateBinding BorderBrush}" 
                                    BorderThickness="{TemplateBinding BorderThickness}" 
                                    CornerRadius="4"/>
                            <Border x:Name="PART_Track" 
                                    CornerRadius="4"/>
                            <Border x:Name="PART_Indicator" 
                                    Background="{TemplateBinding Foreground}" 
                                    BorderBrush="{TemplateBinding Foreground}" 
                                    BorderThickness="0" 
                                    CornerRadius="4" 
                                    HorizontalAlignment="Left">
                                <Border.Effect>
                                    <DropShadowEffect Color="#40000000" Direction="0" ShadowDepth="0" BlurRadius="3"/>
                                </Border.Effect>
                            </Border>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        
        <!-- Card Panel Style -->
        <Style x:Key="CardPanel" TargetType="Border">
            <Setter Property="Background" Value="White"/>
            <Setter Property="BorderBrush" Value="#DEE2E6"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="CornerRadius" Value="6"/>
            <Setter Property="Padding" Value="10"/>
            <Setter Property="Margin" Value="0,0,0,16"/>
            <Setter Property="Effect">
                <Setter.Value>
                    <DropShadowEffect Direction="270" ShadowDepth="2" BlurRadius="6" Opacity="0.1" Color="Black"/>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>

        <!-- Header with Gradient -->
        <Border Grid.Row="0" Margin="0,0,0,12" CornerRadius="6">
            <Border.Effect>
                <DropShadowEffect ShadowDepth="2" Direction="270" BlurRadius="6" Opacity="0.2" Color="Black"/>
            </Border.Effect>
            <Border.Background>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                    <GradientStop Color="#512888" Offset="0.0"/>
                    <GradientStop Color="#3F216B" Offset="0.7"/>
                    <GradientStop Color="#2D184D" Offset="1.0"/>
                </LinearGradientBrush>
            </Border.Background>
            <Grid Margin="10,12">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <Border Width="32" Height="32" CornerRadius="24" Background="White" Margin="0,0,15,0" VerticalAlignment="Center">
                    <TextBlock Text="AFD" FontFamily="Segoe UI" FontWeight="Bold" FontSize="16" 
                              Foreground="#512888" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <TextBlock Grid.Column="1" Style="{StaticResource HeaderTextBlockStyle}" 
                           Text="AnyFlip GUI Downloader. A user friendly GUI for Lofter1's script " VerticalAlignment="Center"/>
            </Grid>
        </Border>
        
        <!-- Content Area -->
        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel>
                <!-- URL Input Card -->
                <Border Style="{StaticResource CardPanel}" Margin="0,0,0,2">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <TextBlock Grid.Row="0" Style="{StaticResource LabelTextBlockStyle}" Text="AnyFlip URL" Margin="0,0,0,4"/>
                        <TextBox Grid.Row="1" x:Name="tbURL" Style="{StaticResource ModernTextBox}"/>
                    </Grid>
                </Border>
                
                <!-- Settings Card -->
                <Border Style="{StaticResource CardPanel}" Margin="0,0,0,2">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="20"/>
                            <ColumnDefinition Width="120"/>
                        </Grid.ColumnDefinitions>
                        
                        <!-- Custom Title -->
                        <Grid Grid.Column="0">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>
                            <TextBlock Grid.Row="0" Style="{StaticResource LabelTextBlockStyle}" Text="Custom Title" Margin="0,0,0,4"/>
                            <TextBlock Grid.Row="1" Style="{StaticResource InfoTextBlockStyle}" 
                                       Text="Optional: Override the default book title from AnyFlip. Leave blank to use default."/>
                            <TextBox Grid.Row="2" x:Name="tbCustomTitle" Style="{StaticResource ModernTextBox}" Margin="0,2,0,0"/>
                        </Grid>
                        
                        <!-- Threads Control -->
                        <Grid Grid.Column="2">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>
                            <TextBlock Grid.Row="0" Style="{StaticResource LabelTextBlockStyle}" Text="Threads" Margin="0,0,0,4"/>
                            <TextBlock Grid.Row="1" Style="{StaticResource InfoTextBlockStyle}" Text="Download speed"/>
                            <TextBox Grid.Row="2" x:Name="tbThreads" Style="{StaticResource ModernTextBox}" Text="4" Margin="0,2,0,0"/>
                        </Grid>
                    </Grid>
                </Border>
                
                <!-- Output Location Card -->
                <Border Style="{StaticResource CardPanel}" Margin="0,0,0,2">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        <TextBlock Grid.Row="0" Style="{StaticResource LabelTextBlockStyle}" Text="Saved PDF Location" Margin="0,0,0,4"/>
                        <TextBlock Grid.Row="1" Style="{StaticResource InfoTextBlockStyle}" 
                                   Text="You can not edit this. AnyFlip Downloader will only download to the folder where it is launched from"/>
                        <TextBox Grid.Row="2" x:Name="tbOutputFolder" Style="{StaticResource ModernTextBox}" IsReadOnly="True" Margin="0,2,0,0"/>
                    </Grid>
                </Border>
                
                <!-- Progress Section -->
                <Border Style="{StaticResource CardPanel}" Padding="12" Margin="0,0,0,12">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        
                        <!-- Progress Bar -->
                        <Grid Grid.Row="0" Margin="0,0,0,10">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <ProgressBar x:Name="progressDownload" Grid.Column="0" Style="{StaticResource ModernProgressBar}" 
                                         Minimum="0" Maximum="100" Value="0" Margin="0,0,10,0"/>
                            <TextBlock x:Name="txtProgress" Grid.Column="1" Text="0%" FontSize="12" FontWeight="SemiBold" 
                                       VerticalAlignment="Center" Foreground="{StaticResource PrimaryColor}"/>
                        </Grid>
                        
                        <!-- Log Output -->
                        <Border Grid.Row="1" BorderBrush="#DEE2E6" BorderThickness="1" CornerRadius="4">
                            <RichTextBox x:Name="tbLog" Style="{StaticResource ModernRichTextBox}" Height="180"/>
                        </Border>
                    </Grid>
                </Border>
                
                <!-- Action Buttons -->
                <Grid Margin="0,2,0,0">
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                        <Button x:Name="btnDownload" Content="Download PDF" Style="{StaticResource PrimaryButton}" Width="180" Margin="0,0,12,0"/>
                        <Button x:Name="btnClose" Content="Close" Style="{StaticResource SecondaryButton}" Width="100"/>
                    </StackPanel>
                </Grid>
            </StackPanel>
        </ScrollViewer>
    </Grid>
</Window>
"@

# Create XML reader with proper settings - skip the Replace method entirely
try {
    $reader = [System.Xml.XmlReader]::Create(
        [System.IO.StringReader]::new($xaml)
    )
    $window = [Windows.Markup.XamlReader]::Load($reader)
    
    # Get UI elements
    $tbURL = $window.FindName("tbURL")
    $tbCustomTitle = $window.FindName("tbCustomTitle")
    $tbThreads = $window.FindName("tbThreads")
    $tbOutputFolder = $window.FindName("tbOutputFolder")
    $progressDownload = $window.FindName("progressDownload")
    $txtProgress = $window.FindName("txtProgress")
    $btnDownload = $window.FindName("btnDownload")
    $btnClose = $window.FindName("btnClose")
    $tbLog = $window.FindName("tbLog")
    
    # Verify elements are found
    if ($null -eq $tbURL -or $null -eq $tbCustomTitle -or $null -eq $tbThreads -or $null -eq $tbOutputFolder -or $null -eq $progressDownload -or 
        $null -eq $txtProgress -or $null -eq $btnDownload -or $null -eq $btnClose -or $null -eq $tbLog) {
        throw "Failed to locate one or more UI elements"
    }
    
    # Reset progress bar
    $progressDownload.Value = 0
    $txtProgress.Text = "0%"
    
    # Set default threads to 4
    $tbThreads.Text = "4"
    
    # Set default output folder to the location from which the script was launched
    if ($PSScriptRoot) {
        # When run as a script file
        $launchLocation = $PSScriptRoot
    } elseif ($psISE) {
        # When run in PowerShell ISE
        $launchLocation = Split-Path -Parent $psISE.CurrentFile.FullPath
    } elseif ($psEditor) {
        # When run in VS Code
        $launchLocation = Split-Path -Parent $psEditor.GetEditorContext().CurrentFile.Path
    } else {
        # Fallback to current directory
        $launchLocation = (Get-Location).Path
    }
    
    # Set the output folder to the launch location
    $tbOutputFolder.Text = $launchLocation
    
    # Script-level variable to store installation path
    $Script:installedToolPath = $null
    
    # Define helper methods for RichTextBox
    function Add-LogMessage {
        param (
            [Parameter(Mandatory=$true)]
            [string]$Message,
            
            [Parameter(Mandatory=$false)]
            [string]$Color = "Black",
            
            [Parameter(Mandatory=$false)]
            [bool]$Bold = $false,
            
            [Parameter(Mandatory=$false)]
            [bool]$Italic = $false,
            
            [Parameter(Mandatory=$false)]
            [bool]$NewLine = $true
        )
        
        $paragraph = New-Object System.Windows.Documents.Paragraph
        $run = New-Object System.Windows.Documents.Run
        $run.Text = $Message
        $run.Foreground = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(
            [System.Convert]::ToByte($Color.Substring(1,2), 16),
            [System.Convert]::ToByte($Color.Substring(3,2), 16),
            [System.Convert]::ToByte($Color.Substring(5,2), 16)))
            
        if ($Bold) { $run.FontWeight = "Bold" }
        if ($Italic) { $run.FontStyle = "Italic" }
        
        $paragraph.Inlines.Add($run)
        $tbLog.Document.Blocks.Add($paragraph)
        
        # Auto-scroll to the end
        $tbLog.ScrollToEnd()
    }
    
    function Add-LogInfo {
        param (
            [Parameter(Mandatory=$true)]
            [string]$Message
        )
        Add-LogMessage -Message $Message -Color "#000000"
    }
    
    function Add-LogSuccess {
        param (
            [Parameter(Mandatory=$true)]
            [string]$Message
        )
        Add-LogMessage -Message $Message -Color "#008800" -Bold $true
    }
    
    function Add-LogWarning {
        param (
            [Parameter(Mandatory=$true)]
            [string]$Message
        )
        Add-LogMessage -Message $Message -Color "#FF8800" -Bold $true
    }
    
    function Add-LogError {
        param (
            [Parameter(Mandatory=$true)]
            [string]$Message
        )
        Add-LogMessage -Message $Message -Color "#FF0000" -Bold $true
    }
    
    function Add-LogHighlight {
        param (
            [Parameter(Mandatory=$true)]
            [string]$Message
        )
        Add-LogMessage -Message $Message -Color "#512888" -Bold $true
    }
    
    # Clear the RichTextBox
    function Clear-Log {
        $tbLog.Document.Blocks.Clear()
    }
    
    # Add initial log message
    Add-LogInfo "Files will be downloaded to: $launchLocation"
    
    # Validate numeric input for threads field
    $tbThreads.Add_TextChanged({
        if ($tbThreads.Text -ne "") {
            # Try to parse the input as an integer
            try {
                $threads = [int]$tbThreads.Text
                # If successful and within reasonable bounds, keep it
                if ($threads -lt 1) { $tbThreads.Text = "1" }
                if ($threads -gt 32) { $tbThreads.Text = "32" }
            } catch {
                # If not a valid integer, revert to previous valid value or default
                $tbThreads.Text = "4"
            }
        }
    })
    
    # Add event handlers
    $btnDownload.Add_Click({
        if ([string]::IsNullOrWhiteSpace($tbURL.Text)) {
            Show-CustomNotification -Message "Please enter an AnyFlip URL" -Title "Missing Information" -Type "Warning"
            return
        }
        
        $outputFolder = $tbOutputFolder.Text
        if ([string]::IsNullOrWhiteSpace($outputFolder) -or -not (Test-Path -Path $outputFolder -PathType Container)) {
            Show-CustomNotification -Message "Invalid output folder. Please restart the application from a valid directory." -Title "Invalid Folder" -Type "Error"
            return
        }
        
        # Check if anyflip-downloader is installed
        $installFolder = $Script:installedToolPath
        if ([string]::IsNullOrEmpty($installFolder)) {
            $installFolder = "$env:LocalAppData\anyflip-downloader"
            
            # Try to load saved installation path
            $configPath = Join-Path -Path ([System.Environment]::GetFolderPath('ApplicationData')) -ChildPath "AnyFlipDownloader\installation_path.txt"
            if (Test-Path -Path $configPath -PathType Leaf) {
                $savedPath = Get-Content -Path $configPath -ErrorAction SilentlyContinue
                if ($savedPath -and (Test-Path -Path $savedPath -PathType Container)) {
                    $installFolder = $savedPath
                    $Script:installedToolPath = $savedPath
                }
            }
        }
        
        $exePath = Join-Path -Path $installFolder -ChildPath "anyflip-downloader.exe"
        
        if (-not (Test-Path -Path $exePath -PathType Leaf)) {
            Add-LogWarning "Installing AnyFlip Downloader by Lofter1 ..."
            
            # Automatically install the tool
            $installResult = InstallAnyflipDownloader
            
            # If installation failed, abort the download
            if (-not $installResult) {
                Add-LogError "Failed to compile requirements. Cannot proceed with download."
                return
            }
            
            Add-LogSuccess "Requirements compiled successfully. Proceeding with download..."
        }
        
        # Start download process
        DownloadBook
    })
    
    $btnClose.Add_Click({
        $window.Close()
    })
    
    # Function to sanitize file names and paths
    function Get-SanitizedPath {
        param (
            [Parameter(Mandatory=$true)]
            [string]$OriginalPath
        )
        
        try {
            # Get directory and file name
            $directory = [System.IO.Path]::GetDirectoryName($OriginalPath)
            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($OriginalPath)
            $extension = [System.IO.Path]::GetExtension($OriginalPath)
            
            # Remove special characters from filename
            $sanitizedFileName = $fileName -replace '[^\w\s\-\.]', '_'
            
            # Create new path
            $sanitizedPath = Join-Path -Path $directory -ChildPath ($sanitizedFileName + $extension)
            
            Add-LogInfo "Original path: $OriginalPath"
            Add-LogInfo "Sanitized path: $sanitizedPath"
            
            return $sanitizedPath
        }
        catch {
            Add-LogError "Error sanitizing path: $_"
            return $OriginalPath # Return original if sanitizing fails
        }
    }
    
    # Function to install anyflip-downloader - Modified to return success/failure
    function InstallAnyflipDownloader {
        # Use default installation location
        $Script:installedToolPath = "$env:LocalAppData\anyflip-downloader"
        
        # Suppress detailed logging - we'll only show a simple message
        
        # Define variables for the repository and tar.gz file name
        $repoOwner = "Lofter1"
        $repoName = "anyflip-downloader"
        $tarGzFileName = "anyflip-downloader.tar.gz"
    
        # Get architecture
        $processorInfo = $Env:PROCESSOR_ARCHITECTURE 
    
        # Check the architecture
        if ($processorInfo -eq "x86") {
            $architecture = "386"
        }
        elseif ($processorInfo -eq "AMD64") {
            $architecture = "amd64"
        }
        elseif ($processorInfo -eq "ARM64") {
            $architecture = "arm64"
        }
        else {
            # Still log critical errors
            Add-LogError "Failed to compile requirements: Architecture not supported."
            return $false
        }
    
        try {
            # Define the GitHub API URL to get the latest release information
            $releaseUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases/latest"
    
            # Use Invoke-RestMethod to retrieve the latest release data
            $latestRelease = Invoke-RestMethod -Uri $releaseUrl
    
            # Get the download URL for the latest release asset
            $downloadUrl = $latestRelease.assets | Where-Object { $_.name -like "*windows_$architecture.tar.gz" } | Select-Object -ExpandProperty browser_download_url
    
            if (-not $downloadUrl) {
                # Still log critical errors
                Add-LogError "Failed to compile requirements: Could not find appropriate package."
                return $false
            }
    
            # Define the folder where you want to install the application
            $installFolder = $Script:installedToolPath
    
            # Create the installation folder if it doesn't exist
            if (-not (Test-Path -Path $installFolder -PathType Container)) {
                New-Item -Path $installFolder -ItemType Directory -Force | Out-Null
            }
    
            # Define the path to save the downloaded tar.gz file
            $tarGzFilePath = Join-Path -Path $installFolder -ChildPath $tarGzFileName
    
            # Use Invoke-WebRequest to download the tar.gz file
            Invoke-WebRequest -Uri $downloadUrl -OutFile $tarGzFilePath
    
            # Expand the downloaded tar.gz file to the installation folder
            tar -xzf $tarGzFilePath -C $installFolder
    
            # Clean up: remove the downloaded tar.gz file
            Remove-Item -Path $tarGzFilePath -Force
    
            # Add the installation folder to the system's PATH environment variable
            [System.Environment]::SetEnvironmentVariable('Path', $env:Path + ";$installFolder", [System.EnvironmentVariableTarget]::User)
            
            # Update the current session's PATH
            $env:Path = $env:Path + ";$installFolder"
            
            # Save the installation path in a file for future use
            $configPath = Join-Path -Path ([System.Environment]::GetFolderPath('ApplicationData')) -ChildPath "AnyFlipDownloader"
            if (-not (Test-Path -Path $configPath -PathType Container)) {
                New-Item -Path $configPath -ItemType Directory -Force | Out-Null
            }
            $installFolder | Out-File -FilePath (Join-Path -Path $configPath -ChildPath "installation_path.txt")
            
            # Return success
            return $true
        }
        catch {
            # Still log critical errors
            Add-LogError "Failed to compile requirements: $_"
            return $false
        }
    }
    
    # Function to download a book
    function DownloadBook {
        $url = $tbURL.Text
        $outputFolder = $tbOutputFolder.Text
        $customTitle = $tbCustomTitle.Text.Trim()
        $threads = $tbThreads.Text.Trim()
        
        try {
            Add-LogHighlight "Starting download from $url"
            Add-LogInfo "Output folder: $outputFolder"
            
            # Build the arguments list
            $arguments = New-Object System.Collections.ArrayList
            
            # Add optional arguments first
            if (-not [string]::IsNullOrEmpty($customTitle)) {
                Add-LogInfo "Using custom title: $customTitle"
                [void]$arguments.Add("-title")
                [void]$arguments.Add("""$customTitle""")
            }
            
            # Add threads if specified and valid
            if (-not [string]::IsNullOrEmpty($threads)) {
                try {
                    $threadsValue = [int]$threads
                    if ($threadsValue -gt 0) {
                        Add-LogInfo "Using $threadsValue download threads"
                        [void]$arguments.Add("-threads")
                        [void]$arguments.Add($threadsValue)
                    }
                } catch {
                    Add-LogWarning "Invalid threads value, using default (1)"
                }
            }
            
            # Always add URL as the LAST argument (positional parameter)
            [void]$arguments.Add("""$url""")
            
            # Reset progress bar
            $progressDownload.Value = 0
            $txtProgress.Text = "0%"
            
            # Record download start time to find new files later
            $downloadStartTime = Get-Date
            
            # Setup output files for streaming
            $outputFile = "$env:TEMP\anyflip_output.txt"
            $errorFile = "$env:TEMP\anyflip_error.txt"
            
            # Clear any existing files
            if (Test-Path $outputFile) { Remove-Item $outputFile -Force }
            if (Test-Path $errorFile) { Remove-Item $errorFile -Force }
            
            # Create empty files to stream to
            New-Item -Path $outputFile -ItemType File -Force | Out-Null
            New-Item -Path $errorFile -ItemType File -Force | Out-Null
            
            # Display the command line being executed
            $exePath = Join-Path -Path $Script:installedToolPath -ChildPath "anyflip-downloader.exe"
            $cmdLine = "$exePath $($arguments -join ' ')"
            Add-LogInfo "Executing command: $cmdLine"
            
            # Run the anyflip-downloader command with simple redirection
            # This approach works better with PS2EXE
            $startInfo = New-Object System.Diagnostics.ProcessStartInfo
            $startInfo.FileName = $exePath
            $startInfo.Arguments = $arguments -join ' '
            $startInfo.WorkingDirectory = $outputFolder
            $startInfo.UseShellExecute = $false
            $startInfo.CreateNoWindow = $true
            $startInfo.RedirectStandardOutput = $true
            $startInfo.RedirectStandardError = $true
            $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

            # Create and start the process
            $process = New-Object System.Diagnostics.Process
            $process.StartInfo = $startInfo
            $process.Start() | Out-Null

            # Set up output and error file handling
            $outputFileStream = [System.IO.File]::CreateText($outputFile)
            $errorFileStream = [System.IO.File]::CreateText($errorFile)

            # Track process and update UI while running
            while (!$process.HasExited) {
                # Force UI to update
                [System.Windows.Forms.Application]::DoEvents()
                
                # Get output from process streams if available
                if ($process.StandardOutput.Peek() -ge 0) {
                    $line = $process.StandardOutput.ReadLine()
                    if ($line) {
                        $outputFileStream.WriteLine($line)
                        $outputFileStream.Flush()
                        
                        # Check for progress percentage in output
                        if ($line -match '(\d+)%') {
                            $percentage = [int]$Matches[1]
                            if ($percentage -ge 0 -and $percentage -le 100) {
                                $progressDownload.Value = $percentage
                                $txtProgress.Text = "$percentage%"
                            }
                        }
                        
                        Add-LogInfo $line
                    }
                }
                
                # Get error output if available
                if ($process.StandardError.Peek() -ge 0) {
                    $line = $process.StandardError.ReadLine()
                    if ($line) {
                        $errorFileStream.WriteLine($line)
                        $errorFileStream.Flush()
                        Add-LogError "Error: $line"
                    }
                }
                
                # Add a periodic status update
                $elapsedSeconds = [math]::Floor(((Get-Date) - $startTime).TotalSeconds)
                if ($elapsedSeconds % 10 -eq 0 -and $Script:lastStatusUpdate -ne $elapsedSeconds) {
                    Add-LogWarning "Still working... ($elapsedSeconds seconds elapsed)"
                    $Script:lastStatusUpdate = $elapsedSeconds
                }
                
                # Sleep for a short time to avoid excessive CPU usage
                Start-Sleep -Milliseconds $refreshInterval
            }

            # Close file streams
            $outputFileStream.Close()
            $errorFileStream.Close()
            
            # Reset UI
            $btnDownload.IsEnabled = $true
            $btnDownload.Content = "Download"
            
            # Small delay to ensure all file operations are complete
            Start-Sleep -Seconds 2
            
            # First check for recently created PDF files, regardless of exit code
            Add-LogInfo "Looking for recently created PDF files..."
            
            # Find PDF files created since download started
            $recentFiles = Get-ChildItem -Path $outputFolder -Filter "*.pdf" -Recurse -ErrorAction SilentlyContinue | 
                           Where-Object { $_.LastWriteTime -gt $downloadStartTime } | 
                           Sort-Object LastWriteTime -Descending
            
            if ($recentFiles.Count -gt 0) {
                # PDF files found - consider this a success regardless of exit code
                $progressDownload.Value = 100
                $txtProgress.Text = "100%"
                
                # Log all found files
                Add-LogSuccess "Download completed successfully."
                Add-LogSuccess "Found $($recentFiles.Count) recently created PDF files:"
                foreach ($file in $recentFiles) {
                    Add-LogHighlight "- $($file.FullName)"
                }
                
                # Get the most recently created file
                $newestFile = $recentFiles[0].FullName
                $fileName = [System.IO.Path]::GetFileName($newestFile)
                
                # Ask if user wants to open the file
                $openFileResponse = Show-CustomNotification `
                    -Message "PDF downloaded successfully to:`n$fileName`n`nWould you like to open it now?" `
                    -Title "Download Complete" `
                    -Type "Success" `
                    -Buttons "YesNo"
                
                if ($openFileResponse -eq [System.Windows.MessageBoxResult]::Yes) {
                    try {
                        # First try: Use Start-Process with explorer.exe
                        Add-LogInfo "Opening file with explorer: $newestFile"
                        Start-Process "explorer.exe" -ArgumentList "`"$newestFile`""
                    }
                    catch {
                        Add-LogError "Could not open file directly: $_"
                        
                        # Second try: Open the containing folder
                        try {
                            $folder = [System.IO.Path]::GetDirectoryName($newestFile)
                            Add-LogWarning "Opening containing folder instead: $folder"
                            Start-Process "explorer.exe" -ArgumentList "`"$folder`""
                            
                            Show-CustomNotification `
                                -Message "Could not open the PDF directly. The folder has been opened instead.`nFile: $fileName" `
                                -Title "Information" `
                                -Type "Information"
                        }
                        catch {
                            Add-LogError "Could not open containing folder: $_"
                            Show-CustomNotification `
                                -Message "The file was downloaded but could not be opened.`nPlease browse to it manually at: $newestFile" `
                                -Title "Warning" `
                                -Type "Warning"
                        }
                    }
                }
            }
            else {
                # No new PDFs found, now check exit code
                if ($process.ExitCode -eq 0) {
                    # Set progress to 100% when download completes successfully
                    $progressDownload.Value = 100
                    $txtProgress.Text = "100%"
                    
                    # Final read of output files
                    if (Test-Path $outputFile) {
                        $finalOutput = Get-Content -Path $outputFile -Raw -ErrorAction SilentlyContinue
                        if ($finalOutput -and $finalOutput.Trim() -ne "") {
                            Add-LogSuccess "Download completed successfully."
                            Add-LogInfo $finalOutput
                        } else {
                            Add-LogSuccess "Download completed successfully."
                        }
                    }
                    
                    # Try to find any PDF files in the output folder as a fallback
                    $anyPdfFiles = Get-ChildItem -Path $outputFolder -Filter "*.pdf" -Recurse -ErrorAction SilentlyContinue |
                                  Sort-Object LastWriteTime -Descending
                    
                    if ($anyPdfFiles.Count -gt 0) {
                        Add-LogInfo "Found existing PDF files in the output folder:"
                        foreach ($file in ($anyPdfFiles | Select-Object -First 5)) {
                            Add-LogInfo "- $($file.FullName) (Last modified: $($file.LastWriteTime))"
                        }
                        
                        Show-CustomNotification `
                            -Message "Download appears to have completed, but no new PDF files were detected.`nCheck the output folder manually." `
                            -Title "Success with Warning" `
                            -Type "Warning"
                    }
                    else {
                        Add-LogError "No PDF files found in the output folder."
                        Show-CustomNotification `
                            -Message "Download completed, but no PDF files were found in the output folder." `
                            -Title "Warning" `
                            -Type "Warning"
                    }
                } else {
                    # Reset progress on error
                    $progressDownload.Value = 0
                    $txtProgress.Text = "Error"
                    
                    $errorContent = Get-Content -Path $errorFile -ErrorAction SilentlyContinue
                    Add-LogError "Error during download (Exit code: $($process.ExitCode))"
                    Add-LogError "$errorContent"
                    
                    Show-CustomNotification `
                        -Message "Error downloading book. Check the log for details." `
                        -Title "Download Failed" `
                        -Type "Error"
                }
            }
        }
        catch {
            # Reset progress on error
            $progressDownload.Value = 0
            $txtProgress.Text = "Error"
            
            Add-LogError "Error: $_"
            Show-CustomNotification -Message "Error: $_" -Title "Error" -Type "Error"
        }
        finally {
            # Ensure UI is reset even after errors
            $btnDownload.IsEnabled = $true
            $btnDownload.Content = "Download"
            
            # Clean up temp files
            Remove-Item -Path "$env:TEMP\anyflip_output.txt" -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:TEMP\anyflip_error.txt" -ErrorAction SilentlyContinue
        }
    }
    
    # Add script-level variable for tracking status updates
    $Script:lastStatusUpdate = 0
    
    # Try to load saved installation path on startup
    $configPath = Join-Path -Path ([System.Environment]::GetFolderPath('ApplicationData')) -ChildPath "AnyFlipDownloader\installation_path.txt"
    if (Test-Path -Path $configPath -PathType Leaf) {
        $savedPath = Get-Content -Path $configPath -ErrorAction SilentlyContinue
        if ($savedPath -and (Test-Path -Path $savedPath -PathType Container)) {
            $Script:installedToolPath = $savedPath
            Add-LogInfo "Using previously installed tool from: $savedPath"
        }
        else {
            Add-LogError "AnyFlip Downloader tool by Lofter1 not detected. It will be installed as part of the download process."
        }
    }
    else {
        Add-LogError "AnyFlip Downloader tool by Lofter1 not detected. It will be installed as part of the download process."
    }
    
    # Show the window
    [void]$window.ShowDialog()

} catch {
    # Error handling for XAML parsing or UI initialization
    Write-Host "Error initializing the application: $_"
    Show-CustomNotification -Message "Error initializing the application: $_" -Title "Error" -Type "Error"
}