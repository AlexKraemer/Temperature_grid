#ifndef PLATE_H
#define PLATE_H

#define gridSize 32

struct Grid {
	double grid[gridSize][gridSize];
};

void solveCorners(float** plateGrid);

float solveGrid(float** plateGrid);

void makeGrid(float** plateGrid);

double calculateGridAverage(Grid* tempGrid);

#endif
