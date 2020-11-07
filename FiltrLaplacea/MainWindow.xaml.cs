using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.ComponentModel;
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
		[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		private static extern IntPtr LoadLibrary(string libname);

		[DllImport("kernel32.dll", CharSet = CharSet.Auto)]
		private static extern bool FreeLibrary(IntPtr hModule);

		[DllImport("kernel32.dll", CharSet = CharSet.Ansi)]
		private static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);

		delegate int laplaceFilter_Delegate();

		[DllImport("gdi32.dll", EntryPoint = "DeleteObject")]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool DeleteObject([In] IntPtr hObject);

		enum ColName { Red, Blue, Green};
		Bitmap bitmapImage;

		//int[] LAPLACE_MASK = new int[] {1,2,1,2,4,2,1,2,1};
		//int[] LAPLACE_MASK = new int[] { 0, -1, 0, -1, 4, -1, 0, -1, 0};
		int[] LAPLACE_MASK = new int[] { 1, 1, 1, 1, -8, 1, 1, 1, 1 };
		int weightSum;

		public MainWindow()
		{
			runInAsm();
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
				bitmapImage = new Bitmap(fileName);
            }
        }

		private void btn_FilterImage(object sender, RoutedEventArgs e)
        {
			System.Drawing.Rectangle rect = new System.Drawing.Rectangle(0, 0, bitmapImage.Width, bitmapImage.Height);
			Bitmap preparedImageBmp = bitmapImage.Clone(rect, System.Drawing.Imaging.PixelFormat.Format24bppRgb);
			System.Drawing.Imaging.BitmapData bmpData = preparedImageBmp.LockBits(rect,
														System.Drawing.Imaging.ImageLockMode.ReadWrite,
														preparedImageBmp.PixelFormat);
			IntPtr ptr = bmpData.Scan0;
			int length = Math.Abs(bmpData.Stride) * preparedImageBmp.Height;

			byte[] pixels = new byte[length];
			System.Runtime.InteropServices.Marshal.Copy(ptr, pixels, 0, length);

            byte[] newImage = laplaceFilter(pixels,
                                            preparedImageBmp.Width,
                                            preparedImageBmp.Height,
                                            pixels.Length);

            System.Runtime.InteropServices.Marshal.Copy(newImage, 0, ptr, length);
			preparedImageBmp.UnlockBits(bmpData);
			ImageEdit.ImageSource = ImageSourceFromBitmap(preparedImageBmp);
        }


		public ImageSource ImageSourceFromBitmap(Bitmap bmp)
		{
			var handle = bmp.GetHbitmap();
			try
			{
				return Imaging.CreateBitmapSourceFromHBitmap(handle, IntPtr.Zero, Int32Rect.Empty, BitmapSizeOptions.FromEmptyOptions());
			}
			finally { DeleteObject(handle); }
		}
		

		private byte[] laplaceFilter(byte[] image, int width, int height, int arrLength)
        {
			Debug.Print("Starting filtration");
			byte[] filtered = new byte[arrLength];

            for (int y = 1; y < height - 1; y++)
            {
                for (int x = 3; x < width * 3 -3; x += 3)
                {
                    //Debug.Print("Pixel[" + y + "," + x / 3 + "] R:" + image[(y) * width + x + 0] + " G:" + image[(y) * width + x + 1] + " B:" + image[(y) * width + x + 2]);
                    int sumR = 0;
                    int sumG = 0;
                    int sumB = 0;
                    int maskIndex = 0;
                    for (int pxY = -1; pxY <= 1; pxY++)
                    {
                        for (int pxX = -1; pxX <= 1; pxX++)
                        {
                            sumR += image[(y - pxY) * width * 3 + x + pxX * 3 + 0] * LAPLACE_MASK[maskIndex];
                            sumG += image[(y - pxY) * width * 3 + x + pxX * 3 + 1] * LAPLACE_MASK[maskIndex];
                            sumB += image[(y - pxY) * width * 3 + x + pxX * 3 + 2] * LAPLACE_MASK[maskIndex];
                            maskIndex++;
                        }
                    }
                    sumR = normalizeRGB(sumR);
                    sumG = normalizeRGB(sumG);
                    sumB = normalizeRGB(sumB);
                    //Debug.Print("new pixel[" + y +"," + x/3 + "] new R:" + sumR +" new G:" + sumG + "new B:" + sumB);
                    filtered[y * width * 3 + x + 2] = (byte)sumR;
                    filtered[y * width * 3 + x + 1] = (byte)sumG;
                    filtered[y * width * 3 + x + 0] = (byte)sumB;

                    /*filtered[y * width * 3 + x + 0] = 255;
					filtered[y * width * 3 + x + 1] = 0;
					filtered[y * width * 3 + x + 2] = 0;*/
				}
            }

            Debug.Print("Done");
			return filtered;
        }

		private System.Drawing.Color transformPixel(System.Drawing.Color[] pixels)
		{
			int newR = normalizeRGB(laplaceCalculation(pixels, ColName.Red));
			int newG = normalizeRGB(laplaceCalculation(pixels, ColName.Green));
			int newB = normalizeRGB(laplaceCalculation(pixels, ColName.Blue));

			return System.Drawing.Color.FromArgb(newR, newG, newB);
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

			return newValue / weightSum;
		}


		int runInAsm()
		{
			IntPtr Handle = LoadLibrary(@"G:\Dokumenty\Uczelnia\JA\projekt\repo\FiltrLaplacea\x64\Debug\asmDLL.dll");
            if (Handle == IntPtr.Zero)
            {
                return Marshal.GetLastWin32Error();
            }
            IntPtr funcaddr = GetProcAddress(Handle, "laplaceFilter");
			laplaceFilter_Delegate function = Marshal.GetDelegateForFunctionPointer(funcaddr, typeof(laplaceFilter_Delegate)) as laplaceFilter_Delegate;
			return function.Invoke();
		}


		private int normalizeRGB(int val)
		{
			if (val < 0) val = 0;
			if (val > 255) val = 255;
			return val;
		}
	}
}
