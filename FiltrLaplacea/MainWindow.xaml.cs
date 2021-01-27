using FiltrLaplace.source;
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

		delegate int laplaceFilter_Delegate(byte[] image, int width, int height, byte[] filteredImage);

		[DllImport("gdi32.dll", EntryPoint = "DeleteObject")]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool DeleteObject([In] IntPtr hObject);

		Bitmap bitmapImage;
		LaplaceFilter laplaceFilter;


		public MainWindow()
		{
			byte[] a = new byte[] { 255, 255, 255, 0, 0, 0, 255, 255, 255, 0, 0, 0, 255, 255, 255, 0, 0, 0, 255, 255, 255, 0, 0, 0, 255, 255, 255 };
			laplaceFilter = new LaplaceFilter();
			//Console.WriteLine("Print from assembler: " + runInAsm());
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

			//printImage(pixels);

			/*
			pixels = new byte[]{ 255, 255, 255, 255, 255, 255, 0, 0, 0, 255, 255, 255, 255, 255, 255,
								 255, 255, 255, 255, 255, 255, 0, 0, 0, 255, 255, 255, 255, 255, 255,
								 255, 255, 255, 255, 255, 255, 0, 0, 0, 255, 255, 255, 255, 255, 255,
								 255, 255, 255, 255, 255, 255, 0, 0, 0, 255, 255, 255, 255, 255, 255,
								 255, 255, 255, 255, 255, 255, 0, 0, 0, 255, 255, 255, 255, 255, 255 };
			*/
			
			byte[] newImage = laplaceFilter.filter(pixels,
                                            preparedImageBmp.Width,
                                            preparedImageBmp.Height,
                                            pixels.Length);
			

			//byte[] newImage = laplaceFilter.filter(pixels, 5, 5, 75);
			//printImage(newImage,preparedImageBmp.Width, preparedImageBmp.Height);
			byte[] newImage2 = new byte[pixels.Length];
			runInAsm(pixels, preparedImageBmp.Width,preparedImageBmp.Height, ref newImage2);
			//printImage(newImage, preparedImageBmp.Width, preparedImageBmp.Height);
			//compareImagesPrint(newImage, newImage2, preparedImageBmp.Width, preparedImageBmp.Height );

			System.Runtime.InteropServices.Marshal.Copy(newImage2, 0, ptr, length);
			preparedImageBmp.UnlockBits(bmpData);
			ImageEdit.ImageSource = ImageSourceFromBitmap(preparedImageBmp);
        }

		private void printImage(byte[] image)
		{
			for(int i = 0; i < image.Length; i++)
            {
				Debug.Print(image[i] + ", ");
            }
		}

		private void printImage(byte[] image, int width, int height)
        {
			for(int y = 0; y<height; y++)
            {
				for (int x = 0; x<width*3; x += 3)
                {
					Debug.Print("y:" + y + ", x:"+ x/3 + " R" + image[y*width*3+x] + " G" + image[y * width * 3 + x + 1] + " B" + image[y * width * 3 + x + 2]);
                }
            }
        }


		private void compareImagesPrint(byte[] image1, byte[] image2, int width, int height)
		{
			for (int y = 0; y < height; y++)
			{
				for (int x = 0; x < width * 3; x += 3)
				{
					Debug.Print("y:" + y + ", x:" + x / 3 + " R" + image1[y * width * 3 + x] + " G" + image1[y * width * 3 + x + 1] + " B" + image1[y * width * 3 + x + 2]
								+ "       " 
								+ "y:" + y + ", x:" + x / 3 + " R" + image2[y * width * 3 + x] + " G" + image2[y * width * 3 + x + 1] + " B" + image2[y * width * 3 + x + 2]);
				}
			}
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
		
		int runInAsm(byte[] image, int width, int height, ref byte[] filteredImage)
		{
			IntPtr Handle = LoadLibrary(@"G:\Dokumenty\Uczelnia\JA\projekt\repo\FiltrLaplacea\x64\Debug\asmDLL.dll");
            if (Handle == IntPtr.Zero)
            {
                return Marshal.GetLastWin32Error();
            }
            IntPtr funcaddr = GetProcAddress(Handle, "laplaceFilter");
			laplaceFilter_Delegate function = Marshal.GetDelegateForFunctionPointer(funcaddr, typeof(laplaceFilter_Delegate)) as laplaceFilter_Delegate;
			return function.Invoke(image, width, height, filteredImage);
		}

	}
}
