using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace FiltrLaplace
{
	/// <summary>
	/// Logika interakcji dla klasy MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window
	{
		public MainWindow()
		{

			InitializeComponent();
			ImageBackground.Opacity = 0;
			Button piwo = new Button();
			BtnAdd.Click += btn_Click;
		}

		private void btn_Click(object sender, RoutedEventArgs e)
        {
			if (ImageBackground.Opacity == 0)
				ImageBackground.Opacity = 100;
			else
				ImageBackground.Opacity = 0;
        }
	}
}
