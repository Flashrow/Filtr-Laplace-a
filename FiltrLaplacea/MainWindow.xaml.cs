using FiltrLaplace.source;
using LiveCharts;
using LiveCharts.Wpf;
using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.Remoting.Messaging;
using System.Text;
using System.Threading;
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
	// Główna klasa projektu
	
	public partial class MainWindow : Window
	{
		[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		private static extern IntPtr LoadLibrary(string libname);

		[DllImport("kernel32.dll", CharSet = CharSet.Auto)]
		private static extern bool FreeLibrary(IntPtr hModule);

		[DllImport("kernel32.dll", CharSet = CharSet.Ansi)]
		private static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);

		[DllImport("gdi32.dll", EntryPoint = "DeleteObject")]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool DeleteObject([In] IntPtr hObject);

		delegate void laplaceFilter_Delegate(byte[] image, int width, int height, byte[] filteredImage);
		laplaceFilter_Delegate laplaceDelegate;

		Bitmap bitmapImage;
		Bitmap preparedImageBmp;
		LaplaceFilter laplaceFilter;

		public SeriesCollection SeriesCollection { get; set; }

		public MainWindow()
		{
			InitializeComponent();
			InitHistogram();
		}

		// obsługa zapisywania przefiltrowanej grafiki
		private void btn_SaveImage(object sender, RoutedEventArgs e)
		{
			SaveFileDialog saveFileDialog = new SaveFileDialog();
			saveFileDialog.Filter = "JPG (*.jpg)|*.jpg|PNG (*.png)|*.png";
			if (saveFileDialog.ShowDialog() == true)
			{
				var fileName = saveFileDialog.FileName;
				var extension = System.IO.Path.GetExtension(saveFileDialog.FileName);

				switch (extension.ToLower())
				{
					case ".jpg":
						preparedImageBmp.Save(fileName, System.Drawing.Imaging.ImageFormat.Jpeg);
						break;
					case ".png":
						preparedImageBmp.Save(fileName, System.Drawing.Imaging.ImageFormat.Png);
						break;
					default:
						throw new ArgumentOutOfRangeException(extension);
				}
			}
			btnSave.IsEnabled = false;
		}

			private void btn_AddImage(object sender, RoutedEventArgs e)
        {


			OpenFileDialog openFileDialog = new OpenFileDialog();
			if(openFileDialog.ShowDialog() == true)
            {
				var fileName = openFileDialog.FileName;
				ImageEdit.ImageSource = new BitmapImage(new Uri(fileName));
				bitmapImage = new Bitmap(fileName);
				CreateHistogram(bitmapImage, SeriesCollection);
			}
        }

		private void btn_FilterImage(object sender, RoutedEventArgs e)
        {
			System.Drawing.Rectangle rect = new System.Drawing.Rectangle(0, 0, bitmapImage.Width, bitmapImage.Height);
			preparedImageBmp = bitmapImage.Clone(rect, System.Drawing.Imaging.PixelFormat.Format24bppRgb);
			System.Drawing.Imaging.BitmapData bmpData = preparedImageBmp.LockBits(rect,
														System.Drawing.Imaging.ImageLockMode.ReadWrite,
														preparedImageBmp.PixelFormat);

			IntPtr ptr = bmpData.Scan0;
			int length = Math.Abs(bmpData.Stride) * preparedImageBmp.Height;

			byte[] pixels = new byte[length];
			//System.Runtime.InteropServices.Marshal.Copy(ptr, pixels, 0, length);

			int pos = 0;
			int offset = Math.Abs(bmpData.Stride) - preparedImageBmp.Width * 3;

			for (int y = 0; y < preparedImageBmp.Height * Math.Abs(bmpData.Stride); y += preparedImageBmp.Width * 3)
			{
				System.Runtime.InteropServices.Marshal.Copy(ptr + y, pixels, pos, preparedImageBmp.Width * 3);
				pos += preparedImageBmp.Width * 3;
				y += offset;
			}

			byte[] newImage = new byte[preparedImageBmp.Height * preparedImageBmp.Width * 3];
			
			filterImage(pixels, 
						preparedImageBmp.Width,
						preparedImageBmp.Height,
						newImage);

			pos = 0;
			for (int i = 0; i < preparedImageBmp.Height * Math.Abs(bmpData.Stride); i += preparedImageBmp.Width * 3)
			{
				System.Runtime.InteropServices.Marshal.Copy(newImage, pos, ptr + i, preparedImageBmp.Width * 3);
				pos += preparedImageBmp.Width * 3;
				i += offset;
			}

			CreateHistogram(newImage, SeriesCollection);
			preparedImageBmp.UnlockBits(bmpData);
			ImageEdit.ImageSource = ImageSourceFromBitmap(preparedImageBmp);
			btnSave.IsEnabled = true;
        }

		void runInAsm(byte[] image, int width, int height, byte[] filteredImage)
		{
			//IntPtr Handle = LoadLibrary(@"G:\Dokumenty\Uczelnia\JA\projekt\repo\FiltrLaplacea\x64\Debug\asmDLL.dll");
			IntPtr Handle = LoadLibrary(@"./asmDLL.dll");
			IntPtr funcaddr = GetProcAddress(Handle, "laplaceFilter");
			laplaceFilter_Delegate function = Marshal.GetDelegateForFunctionPointer(funcaddr, typeof(laplaceFilter_Delegate)) as laplaceFilter_Delegate;
			function.Invoke(image, width, height, filteredImage);
		}

		void runInCs(byte[] image, int width, int height, byte[] filteredImage)
		{
			//var DLL = Assembly.LoadFile(@"G:\Dokumenty\Uczelnia\JA\projekt\repo\CsDll\bin\Debug\CsDll.dll");
			var dllFile = new FileInfo(@"./CsDll.dll");
			var DLL = Assembly.LoadFile(dllFile.FullName);
			var class1Type = DLL.GetType("CsDll.Class1");
			dynamic c = Activator.CreateInstance(class1Type);
			c.filter(image, width, height, filteredImage);
		}

		private void filterImage(byte[] image, int width, int height, byte[] newImage)
        {
            if (RadioAsm.IsChecked == true)
            {
				laplaceDelegate = runInAsm;
			}
			else
            {
				laplaceDelegate = runInCs;
            }

			Stopwatch stopWatch = new Stopwatch();

			int numberOfThreads = (int)threadNumberSlider.Value;

			stopWatch.Start();
			//laplaceDelegate(image, width, height, newImage);
			multiThreadFiltering(numberOfThreads, image, width, height, newImage);
			stopWatch.Stop();
			setTimerLabel(stopWatch.ElapsedMilliseconds);

			//btnFilter.IsEnabled = false;
		}

		void multiThreadFiltering(int numberOfThreads, byte[] image, int width, int height, byte[] newImage)
        {
            if (numberOfThreads > height)
            {
				numberOfThreads = height;
            }

			int moduloHeight = height % numberOfThreads;
			int subArrayHeight = (int)(height / numberOfThreads);

			byte[][] subArrays = new byte[numberOfThreads][];
			byte[][] filteredSubArrays = new byte[numberOfThreads][];

			int subArrayPosition = 0;

			List<Thread> threads = new List<Thread>();

			for (int y = 0; y< height - moduloHeight - 1; y+= subArrayHeight)
            {
				int startIndex = y;
				int endIndex = y + subArrayHeight;			

				if (moduloHeight > 0)
                {
					endIndex += 1;
					moduloHeight--;
					y++;
                }

				if (startIndex > 0)
					startIndex -= 1;

				if (endIndex < height)
					endIndex += 1;

				//subArrays[subArrayPosition] = image.Take(7).ToArray();

				subArrays[subArrayPosition] = new byte[endIndex * width * 3 - startIndex * width * 3];

				//Debug.WriteLine("Array length:" + image.Length);
				//Debug.WriteLine("Sub array height:" + subArrayHeight);
				//Debug.WriteLine("Start index:" + startIndex + ", array position:" + startIndex * width * 3);
				//Debug.WriteLine("End index:" + endIndex + ", array position:" + endIndex * width * 3);

				int tempArrayPosition = subArrayPosition;
				Array.Copy(image,	
								startIndex * width * 3, 
								subArrays[tempArrayPosition],
								0,
								endIndex * width * 3 - startIndex * width * 3);

				//Debug.WriteLine("thread height parameter: " + (endIndex - startIndex));
				//Debug.WriteLine("New " + (endIndex - startIndex));

				filteredSubArrays[tempArrayPosition] = new byte[endIndex * width * 3 - startIndex * width * 3];

				FilteringData data = new FilteringData(subArrays[tempArrayPosition], width, endIndex - startIndex, filteredSubArrays[tempArrayPosition], laplaceDelegate);

				Thread thread = new Thread(data.filtering);
				thread.Start(data);
				threads.Add(thread);
				
				subArrayPosition++;
				Task.Delay(2000);
			}


			int currentHeight = 0;
			int subImageHeightSum = 0;
			for(int i = 0; i < numberOfThreads; i++)
            {
				threads[i].Join();
				byte[] subImage = filteredSubArrays[i];
				//printImage(subImage,width, subImage.Length / (width * 3));
				//Debug.WriteLine("Thread "+ i + " array length: " + subImage.Length);
				//Debug.WriteLine("Thread "+ i + " array height: " + subImage.Length/ (width * 3));

				subImageHeightSum += subImage.Length / (width * 3);

				//Debug.WriteLine("New image length:" + newImage.Length);
				//Debug.WriteLine("current position:" + currentHeight * width * 3);
				//Debug.WriteLine("end position:" + (currentHeight * width * 3 + (subImage.Length - width * 3)));

				if (i == 0)
                {
					Array.Copy(subImage,
								0,
								newImage,
								currentHeight,
								subImage.Length - width*3);
					currentHeight += subImage.Length / (width * 3) - 1;
					
				}
				else
                {				
					Array.Copy(subImage,
								width*3,
								newImage,
								currentHeight * width * 3,
								subImage.Length - width * 3);
					
					currentHeight += subImage.Length / (width * 3) - 2;
					
				}
				//printImage(subImage, width, subImage.Length / (width*3));
            }
			//Debug.WriteLine("Sub images height sum: " + subImageHeightSum);
			//Debug.WriteLine("Picture height: " + height);
			//Debug.WriteLine("Filtered Image:");
			//printImage(newImage, width, height);
		}

		class FilteringData
		{
			private byte[] image;
			private int width;
			private int height;
			private byte[] filtered;
            private laplaceFilter_Delegate laplaceDelegate;

            public FilteringData(byte[] image, int width, int height, byte[] filtered, laplaceFilter_Delegate fun_delegate)
            {
				this.image = image;
				this.width = width;
				this.height = height;
				this.filtered = filtered;
				this.laplaceDelegate = fun_delegate;

				Debug.WriteLine("Image array:" + this.image);
				Debug.WriteLine("Filtered array:" + this.filtered);
            }

            public void filtering(object data)
            {
				FilteringData cast = (FilteringData)data;
				cast.laplaceDelegate(cast.image, cast.width, cast.height, cast.filtered);
			}
		};

		void setTimerLabel(long elapsedMs)
        {
			timerLabel.Content = elapsedMs.ToString() + " ms";
		}

		private void InitHistogram()
		{
			chart.AxisY.Clear();
			chart.AxisY.Add(
				new Axis
				{
					MinValue = 0
				}
			);

			SeriesCollection = new SeriesCollection
			{
				new LineSeries
				{
					Title = "Red",
					PointGeometry = null,
					Values = new ChartValues<int>{},
					Stroke = System.Windows.Media.Brushes.Red
				},
				new LineSeries
				{
					Title = "Green",
					PointGeometry = null,
					Values = new ChartValues<int>{},
					Stroke = System.Windows.Media.Brushes.Green
				},
				new LineSeries
				{
					Title = "Blue",
					PointGeometry = null,
					Values = new ChartValues<int>{},
					Stroke = System.Windows.Media.Brushes.Blue
				}
			};
			DataContext = this;
		}

		private void CreateHistogram(Bitmap bitmap, SeriesCollection series)
		{
			System.Drawing.Rectangle rect = new System.Drawing.Rectangle(0, 0, bitmapImage.Width, bitmapImage.Height);
			Bitmap preparedImageBmp = bitmapImage.Clone(rect, System.Drawing.Imaging.PixelFormat.Format24bppRgb);
			System.Drawing.Imaging.BitmapData bmpData = preparedImageBmp.LockBits(rect,
														System.Drawing.Imaging.ImageLockMode.ReadWrite,
														preparedImageBmp.PixelFormat);

			IntPtr ptr = bmpData.Scan0;
			int length = Math.Abs(bmpData.Stride) * preparedImageBmp.Height;
			byte[] rgbValues = new byte[length];

			System.Runtime.InteropServices.Marshal.Copy(ptr, rgbValues, 0, length);

			int[] R = new int[256];
			int[] G = new int[256];
			int[] B = new int[256];

			series[0].Values.Clear();
			series[1].Values.Clear();
			series[2].Values.Clear();

			for (int i = 0; i < 256; i++)
			{
				R[i] = 0;
				G[i] = 0;
				B[i] = 0;
			}

			for (int i = 0; i < rgbValues.Length - 3; i += 3)
			{
				R[(int)rgbValues[i]]++;
				G[(int)rgbValues[i + 1]]++;
				B[(int)rgbValues[i + 2]]++;
			}

			for (int i = 0; i < 256; i++)
			{
				series[0].Values.Add(R[i]);
				series[1].Values.Add(G[i]);
				series[2].Values.Add(B[i]);
			}
		}

		private void CreateHistogram(byte[] rgbValues, SeriesCollection series)
		{
			int[] R = new int[256];
			int[] G = new int[256];
			int[] B = new int[256];

			series[0].Values.Clear();
			series[1].Values.Clear();
			series[2].Values.Clear();

			for (int i = 0; i < 256; i++)
			{
				R[i] = 0;
				G[i] = 0;
				B[i] = 0;
			}

			for (int i = 0; i < rgbValues.Length - 3; i += 3)
			{
				R[(int)rgbValues[i]]++;
				G[(int)rgbValues[i + 1]]++;
				B[(int)rgbValues[i + 2]]++;
			}

			for (int i = 0; i < 256; i++)
			{
				series[0].Values.Add(R[i]);
				series[1].Values.Add(G[i]);
				series[2].Values.Add(B[i]);
			}
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
	}
}
