//
//  ObjCINPoint.h
//  IndoorNavi
//
//  Created by Michał Pastwa on 16.06.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

/**
 *  @typedef INPoint
 *
 *  @brief Returns an `INPoint` with the specified coordinates.
 *
 *  @field x The x-coordinate of the point to construct.
 *  @field y The y-coordinate of the point to construct.
 */
typedef struct INPoint {
    /// The x-coordinate of the point to construct.
    int x;
    /// The x-coordinate of the point to construct.
    int y;
} INPoint;

/**
 *  @brief Structure representing a point on the map in centimiters as integers from real distances.
 *
 *  @param x The x-coordinate of the point to construct.
 *  @param y The y-coordinate of the point to construct.
 *
 *  @return A point.
 */
INPoint
INPointMake(int x, int y)
{
    struct INPoint p; p.x = x; p.y = y; return p;
}
