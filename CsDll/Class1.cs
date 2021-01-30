using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CsDll
{
    public class Class1
    {

        enum ColName { Red, Blue, Green };

        //int[] LAPLACE_MASK = new int[] {1,2,1,2,4,2,1,2,1};
        //int[] LAPLACE_MASK = new int[] { 0, -1, 0, -1, 4, -1, 0, -1, 0};
        private int[] LAPLACE_MASK = new int[] { 1, 1, 1, 1, -8, 1, 1, 1, 1 };

        public void filter(byte[] image, int width, int height, byte[] filtered)            // filtr Laplace'a maskujący
        {
            for (int y = 1; y < height - 1; y++)                        // pętla po wartościach Y obrazu
            {
                for (int x = 3; x < width * 3 - 3; x += 3)              // pętla po wartościach X obrazu, uwzględniając, że każdy piksel posiada trzy wartości R,G,B
                {
                    int sumR = 0;
                    int sumG = 0;
                    int sumB = 0;
                    int maskIndex = 0;
                    for (int pxY = -1; pxY <= 1; pxY++)                 //
                    {                                                   // pętle otaczające dookoła piksel, dla którego jest aktualnie wyznaczana nowa wartość
                        for (int pxX = -1; pxX <= 1; pxX++)             //
                        {
                            sumR += image[(y - pxY) * width * 3 + x + pxX * 3 + 0] * LAPLACE_MASK[maskIndex];       // nałożenie maski na każdy kolor
                            sumG += image[(y - pxY) * width * 3 + x + pxX * 3 + 1] * LAPLACE_MASK[maskIndex];       // i dodanie do odpowiedniej sumy
                            sumB += image[(y - pxY) * width * 3 + x + pxX * 3 + 2] * LAPLACE_MASK[maskIndex];       // 
                            maskIndex++;
                        }   
                    }                                                           // sposób wybierania pozycji:
                                                                                // wybór rzędu: (odpowiedni rząd Y - przesunięcie względem środkowego piksela) * szerokość obrazka * 3(RGB)
                    sumR = normalizeRGB(sumR);                                  // wybór kolumny: x(które już uwzględnia RGB) + przesunięcie względem środkowego piksela *3 + wartość koloru (R=0, G=1, B=2)
                    sumG = normalizeRGB(sumG);
                    sumB = normalizeRGB(sumB);

                    filtered[y * width * 3 + x + 2] = (byte)sumR;               // zapisanie nowych wartości
                    filtered[y * width * 3 + x + 1] = (byte)sumG;
                    filtered[y * width * 3 + x + 0] = (byte)sumB;
                }
            }
        }

        private int normalizeRGB(int val)                       // funkcja ograniczająca wynik do zakresu 0 - 255
        {
            if (val < 0) val = 0;
            if (val > 255) val = 255;
            return val;
        }
    }
}
