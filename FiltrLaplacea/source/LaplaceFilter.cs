using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FiltrLaplace.source
{
    class LaplaceFilter
    {
        enum ColName { Red, Blue, Green };

        //int[] LAPLACE_MASK = new int[] {1,2,1,2,4,2,1,2,1};
        //int[] LAPLACE_MASK = new int[] { 0, -1, 0, -1, 4, -1, 0, -1, 0};
        private int[] LAPLACE_MASK = new int[] { 1, 1, 1, 1, -8, 1, 1, 1, 1 };

        public void filter (byte[] image, int width, int height, byte[] filtered)
        {
            for (int y = 1; y < height - 1; y++)
            {
                for (int x = 3; x < width * 3 - 3; x += 3)
                {
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

                    filtered[y * width * 3 + x + 2] = (byte)sumR;
                    filtered[y * width * 3 + x + 1] = (byte)sumG;
                    filtered[y * width * 3 + x + 0] = (byte)sumB;
                }
            }
        }

        private int normalizeRGB(int val)
        {
            if (val < 0) val = 0;
            if (val > 255) val = 255;
            return val;
        }
    }
}
