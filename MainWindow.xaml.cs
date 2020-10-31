using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Runtime.Remoting.Messaging;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Interop;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

using Color = System.Drawing.Color;

namespace FiltrLaplace
{
	/// <summary>
	/// Logika interakcji dla klasy MainWindow.xaml
	/// </summary>
	
	public partial class MainWindow : Window
	{
		enum ColName { Red, Blue, Green};
		Bitmap image;
		//int[] LAPLACE_MASK = new int[] {1,2,1,2,4,2,1,2,1};
		int[] LAPLACE_MASK = new int[] { 0, -1, 0, -1, 4, -1, 0, -1, 0};
		//int[] LAPLACE_MASK = new int[] { 1, 1, 1, 1, -8, 1, 1, 1, 1 };
		int weightSum;

		public MainWindow()
		{
			Console.WriteLine("dupa");
			weightSum = 1;
			//Array.ForEach(LAPLACE_MASK, delegate (int i) { weightSum += i; });
			InitializeComponent();
		}

		private void btn_AddImage(object sender, RoutedEventArgs e)
        {
			OpenFileDialog openFileDialog = new OpenFileDialog();
			if(openFileDialog.ShowDialog() == true)
            {
				var fileName = openFileDialog.FileName;
				ImageEdit.ImageSource = new BitmapImage(new Uri(fileName));
				image = new Bitmap(fileName);
            }
        }

		private void btn_FilterImage(object sender, RoutedEventArgs e)
        {
			ImageEdit.ImageSource = ImageSourceFromBitmap(laplaceFilter(image));
        }

		[DllImport("gdi32.dll", EntryPoint = "DeleteObject")]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool DeleteObject([In] IntPtr hObject);

		public ImageSource ImageSourceFromBitmap(Bitmap bmp)
		{
			var handle = bmp.GetHbitmap();
			try
			{
				return Imaging.CreateBitmapSourceFromHBitmap(handle, IntPtr.Zero, Int32Rect.Empty, BitmapSizeOptions.FromEmptyOptions());
			}
			finally { DeleteObject(handle); }
		}

		private int normalizeRGB(int val)
        {
			if (val < 0) val = 0;
			if (val > 255) val = 255;
			return val;
        }
		private System.Drawing.Color transformPixel(System.Drawing.Color[] pixels)
        {
            /*			int newR = laplaceCalculation(pixels, 0);
                        int newG = laplaceCalculation(pixels, 1);
                        int newB = laplaceCalculation(pixels, 2);*/

            int newR = normalizeRGB(laplaceCalculation(pixels, ColName.Red));
            int newG = normalizeRGB(laplaceCalculation(pixels, ColName.Green));
            int newB = normalizeRGB(laplaceCalculation(pixels, ColName.Blue));

            return System.Drawing.Color.FromArgb(newR,newG,newB);
		}

		private int laplaceCalculation(Color[] pixels, ColName type)
        {
			int newValue = 0;

			switch (type)
            {
				case ColName.Red:
					for (int i = 0; i < pixels.Length; i++)
						newValue += LAPLACE_MASK[i] * pixels[i].R;
					break;
				case ColName.Green:
					for (int i = 0; i < pixels.Length; i++)
						newValue += LAPLACE_MASK[i] * pixels[i].G;
					break;
				case ColName.Blue:
					for (int i = 0; i < pixels.Length; i++)
						newValue += LAPLACE_MASK[i] * pixels[i].B;
					break;
			}

			return newValue/weightSum;
        }

		private Bitmap laplaceFilter(Bitmap inputImage)
        {
			Bitmap filteredImage = new Bitmap(inputImage);
			
			for(int x = 1; x <= inputImage.Width - 2; x++)
            {
				for(int y = 1; y <= inputImage.Height - 2; y++)
                {
					
					Color[] pixelsArray = { inputImage.GetPixel(x-1, y+1),		 inputImage.GetPixel(x, y+1),	inputImage.GetPixel(x+1, y+1),
											inputImage.GetPixel(x-1, y),		 inputImage.GetPixel(x, y),		inputImage.GetPixel(x+1, y),
											inputImage.GetPixel(x - 1, y - 1),   inputImage.GetPixel(x, y - 1), inputImage.GetPixel(x + 1, y - 1)
											};
					Color newPixel = transformPixel(pixelsArray);
					filteredImage.SetPixel(x, y, newPixel);
                }
            }

			return filteredImage;
        }

	}
}
