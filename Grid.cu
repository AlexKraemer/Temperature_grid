/* Grid.cu
 * ---------------
 * This program aims to calculate the average temerature of a 2D array using
 * single and parallel approaches.  The border of the 2D array will contain
 * preset temperatures which will not change. To calculate the temperature of
 * the inner elements, the average of the four surrounding elements is calculated.
 * The program shall iterate over the array until the sum of error, or difference
 * between new values being calculated and old values, is sufficiantly low.
 *
 * @author Alex Kraemer
 * @version October 28, 2014
 */

#include <stdlib.h>
#include <stdio.h>
#include "Plate.h"

 __global__ void kernel(float** plateGrid)
{

    int posX = blockIdx.x * blockDim.x + threadIdx.x;
    int posY = blockIdx.y * blockDim.y + threadIdx.y;

	temp = plateGrid[posX + 1][posY] + plateGrid[posX][posY + 1] + plateGrid[posX - 1][posY] + plateGrid [posX][posY - 1];
	err += abs((temp *.25) - plateGrid[posX][posY]);
	plateGrid[posX][posY] = (temp *.25);
}

/*
* calculateGridAverage returns the average temerature of the grid.
*/
float calculateGridAverage(float** plateGrid)
{
	float tempAverage = 0;
	for (int i = 0; i < gridSize; i++)
	{
		for (int j = 0; j < gridSize; j++)
		{
			tempAverage += plateGrid[i][j];
		}
	}
	return (tempAverage / (gridSize * gridSize));
}


/*
* solveGrid iterates over the 2D array and calculates the new average for
* for each cell by taking the average of the cells adjacent to it.  After
* a new value is calculated, the cell's error (abs new - old) is calculated
* and added to this iterations total error.  The new value is then placed
* in that cell.
*/
float solveGrid(float** plateGrid)
{
	double temp;
	double err = 0;
	for (int i = 1; i < gridSize - 1; i++)
	{
		for (int j = 1; j < gridSize - 1; j++)
		{
			temp = plateGrid[i + 1][j] + plateGrid[i][j + 1] + plateGrid[i - 1][j]
				+ plateGrid [i][j - 1];

			err += abs((temp *.25) - plateGrid[i][j]);
			plateGrid[i][j] = (temp *.25);
		}
	}
	return err;
}

/*
* Corners need only to be calculated once, as border values do not change.
*/
void solveCorners(float** plateGrid)
{
	plateGrid[0][0] = ((plateGrid[0][1] + plateGrid[1][0]) * .5);

	plateGrid[0][gridSize - 1] = ((plateGrid[0][gridSize - 2]
		+ plateGrid[1][gridSize - 1]) * .5);

	plateGrid[gridSize - 1][gridSize - 1] = ((plateGrid[gridSize - 1][gridSize - 2]
		+ plateGrid[gridSize - 2][gridSize - 1]) * .5);

	plateGrid[gridSize - 1][0] = ((plateGrid[gridSize - 1][1]
		+ plateGrid[gridSize - 2][0]) * .5);
}

/*
* makeGrid sets each edge of the 2D array to the desired values.
*/
void makeGrid(float** plateGrid)
{
	for (int i = 1; i < gridSize - 1; i++)
	{
		plateGrid[i][0] = (44.0f);
		plateGrid[i][gridSize - 1] = (80.0f);
		plateGrid[0][i] = (25.0f);
		plateGrid[gridSize - 1][i] = (92.0f);
	}
}

int main()
{

	/*
	* Single threaded solution for solving the grid.
	*/

	float** grid;

	grid = (float**)malloc(gridSize * sizeof(float*));

	for (int i = 0; i < gridSize; i++)
	{
  		grid[i] = (float*)malloc(gridSize * sizeof(float));
	}

	makeGrid(grid);
	solveCorners(grid);

	while(solveGrid(grid) > .5){

	}

	printf("The average temperature is: %.2f\n", calculateGridAverage(grid));

	free(grid);



	/*
	* Cuda implementation.
	* currently non-functioning.
	*/

	int num_bytes = gridSize * gridSize * sizeof(float);

	float** grid_device;
	float** grid_destination;

	makeGrid(grid);
	solveCorners(grid);

	dim3 block_size(8,8);
	dim3 grid_size(1,1);

	size_t pitch;

	cudaMallocPitch(&grid_device, &pitch, gridSize * sizeof(float), gridSize);
	kernel<<<grid_size,block_size>>>(grid_device);
	printf("kernel call%d\n", 1);
	printf("CUDA error: %s\n", cudaGetErrorString(cudaGetLastError()));

	cudaMemcpy(grid, grid_device, num_bytes, cudaMemcpyDeviceToHost);
	printf("CUDA error: %s\n", cudaGetErrorString(cudaGetLastError()));
}
