/** @file MaxRectsBinPack.h
    @author Jukka

    @brief Implements different bin packer algorithms that use the MAXRECTS data structure.

    This work is released to Public Domain, do whatever you want with it.
*/
#pragma once

#include <vector>
#include <cassert>

namespace rbp {

struct RectSize
{
    int width;
    int height;
    int sizeId;
};

struct Rect
{
    int x;
    int y;
    int width;
    int height;
    int sizeId; // size id
    int isR; // 是否被旋转
};

/// Returns true if a is contained in b.
bool IsContainedIn(const Rect &a, const Rect &b);

class DisjointRectCollection
{
public:
    std::vector<Rect> rects;

    bool Add(const Rect &r)
    {
        // Degenerate rectangles are ignored.
        if (r.width == 0 || r.height == 0)
            return true;

        if (!Disjoint(r))
            return false;
        rects.push_back(r);
        return true;
    }

    void Clear()
    {
        rects.clear();
    }

    bool Disjoint(const Rect &r) const
    {
        // Degenerate rectangles are ignored.
        if (r.width == 0 || r.height == 0)
            return true;

        for(size_t i = 0; i < rects.size(); ++i)
            if (!Disjoint(rects[i], r))
                return false;
        return true;
    }

    static bool Disjoint(const Rect &a, const Rect &b)
    {
        if (a.x + a.width <= b.x ||
            b.x + b.width <= a.x ||
            a.y + a.height <= b.y ||
            b.y + b.height <= a.y)
            return true;
        return false;
    }
};

/** MaxRectsBinPack implements the MAXRECTS data structure and different bin packing algorithms that
    use this structure. */
class MaxRectsBinPack
{
public:
    /// Instantiates a bin of size (0,0). Call Init to create a new bin.
    MaxRectsBinPack();

    /// Instantiates a bin of the given size.
    MaxRectsBinPack(int width, int height);

    /// (Re)initializes the packer to an empty bin of width x height units. Call whenever
    /// you need to restart with a new bin.
    void Init(int width, int height);

    /// Specifies the different heuristic rules that can be used when deciding where to place a new rectangle.
    enum FreeRectChoiceHeuristic
    {
        RectBestShortSideFit, ///< -BSSF: Positions the rectangle against the short side of a free rectangle into which it fits the best.
        RectBestLongSideFit, ///< -BLSF: Positions the rectangle against the long side of a free rectangle into which it fits the best.
        RectBestAreaFit, ///< -BAF: Positions the rectangle into the smallest free rect into which it fits.
        RectBottomLeftRule, ///< -BL: Does the Tetris placement.
        RectContactPointRule ///< -CP: Choosest the placement where the rectangle touches other rects as much as possible.
    };

    /// Inserts the given list of rectangles in an offline/batch mode, possibly rotated.
    /// @param rects The list of rectangles to insert. This vector will be destroyed in the process.
    /// @param dst [out] This list will contain the packed rectangles. The indices will not correspond to that of rects.
    /// @param method The rectangle placement rule to use when packing.
    // ... 测了一下发现结果不对,原来居然是这个API其实并没有实现 而且文档上没有说明,看了代码才知道
    void Insert(std::vector<RectSize> &rects, std::vector<Rect> &dst, FreeRectChoiceHeuristic method);

#if 0
    /// Inserts a single rectangle into the bin, possibly rotated.
    Rect Insert(int width, int height, FreeRectChoiceHeuristic method);
#endif
    /// Computes the ratio of used surface area to the total bin area.
    float Occupancy() const;

private:
    int binWidth;
    int binHeight;

    std::vector<Rect> usedRectangles;
    std::vector<Rect> freeRectangles;

    /// Computes the placement score for placing the given rectangle with the given method.
    /// @param score1 [out] The primary placement score will be outputted here.
    /// @param score2 [out] The secondary placement score will be outputted here. This isu sed to break ties.
    /// @return This struct identifies where the rectangle would be placed if it were placed.
    Rect ScoreRect(int width, int height, int size_id, FreeRectChoiceHeuristic method, int &score1, int &score2) const;

    /// Places the given rectangle into the bin.
    void PlaceRect(std::vector<Rect> &dst, const Rect &node);

    /// Computes the placement score for the -CP variant.
    int ContactPointScoreNode(int x, int y, int width, int height) const;

    Rect FindPositionForNewNodeBottomLeft(int width, int height, int &bestY, int &bestX) const;
    Rect FindPositionForNewNodeBestShortSideFit(int width, int height, int &bestShortSideFit, int &bestLongSideFit) const;
    Rect FindPositionForNewNodeBestLongSideFit(int width, int height, int &bestShortSideFit, int &bestLongSideFit) const;
    Rect FindPositionForNewNodeBestAreaFit(int width, int height, int &bestAreaFit, int &bestShortSideFit) const;
    Rect FindPositionForNewNodeContactPoint(int width, int height, int &contactScore) const;

    /// @return True if the free node was split.
    bool SplitFreeNode(Rect freeNode, const Rect &usedNode);

    /// Goes through the free rectangle list and removes any redundant entries.
    void PruneFreeList();
};

}

