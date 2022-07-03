/** @file MaxRectsBinPack.cpp
    @author Jukka

    @brief Implements different bin packer algorithms that use the MAXRECTS data structure.

    This work is released to Public Domain, do whatever you want with it.
*/
#include <utility>
#include <limits>

#include <iostream>
#include <cassert>
#include <cstring>
#include <cmath>

#include "MaxRectsBinPack.h"

using namespace std;

namespace rbp {


bool IsContainedIn(const Rect &a, const Rect &b)
{
    return a.x >= b.x && a.y >= b.y
        && a.x+a.width <= b.x+b.width
        && a.y+a.height <= b.y+b.height;
}

MaxRectsBinPack::MaxRectsBinPack()
:binWidth(0),
binHeight(0)
{
}

MaxRectsBinPack::MaxRectsBinPack(int width, int height)
{
    Init(width, height);
}

void MaxRectsBinPack::Init(int width, int height)
{
    binWidth = width;
    binHeight = height;

    Rect n;
    n.x = 0;
    n.y = 0;
    n.width = width;
    n.height = height;

    usedRectangles.clear();

    freeRectangles.clear();
    freeRectangles.push_back(n);
}

Rect MaxRectsBinPack::Insert(int width, int height, int size_id, FreeRectChoiceHeuristic method)
{
    Rect newNode;
    int score1; // Unused in this function. We don't need to know the score after finding the position.
    int score2;
    switch(method)
    {
        case RectBestShortSideFit: newNode = FindPositionForNewNodeBestShortSideFit(width, height, score1, score2); break;
        case RectBottomLeftRule: newNode = FindPositionForNewNodeBottomLeft(width, height, score1, score2); break;
        case RectContactPointRule: newNode = FindPositionForNewNodeContactPoint(width, height, score1); break;
        case RectBestLongSideFit: newNode = FindPositionForNewNodeBestLongSideFit(width, height, score2, score1); break;
        case RectBestAreaFit: newNode = FindPositionForNewNodeBestAreaFit(width, height, score1, score2); break;
    }

    if (newNode.height == 0)
        return newNode;

    newNode.sizeId = size_id;
    newNode.isR = newNode.width == width ? 0 : 1;

    size_t numRectanglesToProcess = freeRectangles.size();
    for(size_t i = 0; i < numRectanglesToProcess; ++i)
    {
        if (SplitFreeNode(freeRectangles[i], newNode))
        {
            freeRectangles.erase(freeRectangles.begin() + i);
            --i;
            --numRectanglesToProcess;
        }
    }

    PruneFreeList();

    usedRectangles.push_back(newNode);
    return newNode;
}

void MaxRectsBinPack::Insert(std::vector<RectSize> &rects, std::vector<Rect> &dst, FreeRectChoiceHeuristic method)
{
    dst.clear();

    while(rects.size() > 0)
    {
        int bestScore1 = std::numeric_limits<int>::max();
        int bestScore2 = std::numeric_limits<int>::max();
        size_t bestRectIndex = -1;
        Rect bestNode;

        for(size_t i = 0; i < rects.size(); ++i)
        {
            int score1;
            int score2;
            Rect newNode = ScoreRect(rects[i].width, rects[i].height,
                    rects[i].sizeId, method, score1, score2);

            if (score1 < bestScore1 || (score1 == bestScore1 && score2 < bestScore2))
            {
                bestScore1 = score1;
                bestScore2 = score2;
                bestNode = newNode;
                bestRectIndex = i;
            }
        }

        if (bestRectIndex == -1)
            return;

        PlaceRect(dst, bestNode);
        rects.erase(rects.begin() + bestRectIndex);
    }
}

void MaxRectsBinPack::PlaceRect(std::vector<Rect> &dst, const Rect &node)
{
    size_t numRectanglesToProcess = freeRectangles.size();
    for(size_t i = 0; i < numRectanglesToProcess; ++i)
    {
        if (SplitFreeNode(freeRectangles[i], node))
        {
            freeRectangles.erase(freeRectangles.begin() + i);
            --i;
            --numRectanglesToProcess;
        }
    }

    PruneFreeList();

    usedRectangles.push_back(node);
    dst.push_back(node);
}

Rect MaxRectsBinPack::ScoreRect(int width, int height, int size_id, FreeRectChoiceHeuristic method, int &score1, int &score2) const
{
    Rect newNode;
    score1 = std::numeric_limits<int>::max();
    score2 = std::numeric_limits<int>::max();
    switch(method)
    {
    case RectBestShortSideFit: newNode = FindPositionForNewNodeBestShortSideFit(width, height, score1, score2); break;
    case RectBottomLeftRule: newNode = FindPositionForNewNodeBottomLeft(width, height, score1, score2); break;
    case RectContactPointRule: newNode = FindPositionForNewNodeContactPoint(width, height, score1);
        score1 = -score1; // Reverse since we are minimizing, but for contact point score bigger is better.
        break;
    case RectBestLongSideFit: newNode = FindPositionForNewNodeBestLongSideFit(width, height, score2, score1); break;
    case RectBestAreaFit: newNode = FindPositionForNewNodeBestAreaFit(width, height, score1, score2); break;
    }

    // Cannot fit the current rectangle.
    if (newNode.height == 0)
    {
        score1 = std::numeric_limits<int>::max();
        score2 = std::numeric_limits<int>::max();
    }

    // david's patch
    newNode.sizeId = size_id;
    newNode.isR = newNode.width == width ? 0 : 1;

    return newNode;
}

/// Computes the ratio of used surface area.
float MaxRectsBinPack::Occupancy() const
{
    unsigned long usedSurfaceArea = 0;
    for(size_t i = 0; i < usedRectangles.size(); ++i)
        usedSurfaceArea += usedRectangles[i].width * usedRectangles[i].height;

    return (float)usedSurfaceArea / (binWidth * binHeight);
}

Rect MaxRectsBinPack::FindPositionForNewNodeBottomLeft(int width, int height, int &bestY, int &bestX) const
{
    Rect bestNode;
    memset(&bestNode, 0, sizeof(Rect));

    bestY = std::numeric_limits<int>::max();

    for(size_t i = 0; i < freeRectangles.size(); ++i)
    {
        // Try to place the rectangle in upright (non-flipped) orientation.
        if (freeRectangles[i].width >= width && freeRectangles[i].height >= height)
        {
            int topSideY = freeRectangles[i].y + height;
            if (topSideY < bestY || (topSideY == bestY && freeRectangles[i].x < bestX))
            {
                bestNode.x = freeRectangles[i].x;
                bestNode.y = freeRectangles[i].y;
                bestNode.width = width;
                bestNode.height = height;
                bestY = topSideY;
                bestX = freeRectangles[i].x;
            }
        }
        if (freeRectangles[i].width >= height && freeRectangles[i].height >= width)
        {
            int topSideY = freeRectangles[i].y + width;
            if (topSideY < bestY || (topSideY == bestY && freeRectangles[i].x < bestX))
            {
                bestNode.x = freeRectangles[i].x;
                bestNode.y = freeRectangles[i].y;
                bestNode.width = height;
                bestNode.height = width;
                bestY = topSideY;
                bestX = freeRectangles[i].x;
            }
        }
    }
    return bestNode;
}

Rect MaxRectsBinPack::FindPositionForNewNodeBestShortSideFit(int width, int height,
    int &bestShortSideFit, int &bestLongSideFit) const
{
    Rect bestNode;
    memset(&bestNode, 0, sizeof(Rect));

    bestShortSideFit = std::numeric_limits<int>::max();

    for(size_t i = 0; i < freeRectangles.size(); ++i)
    {
        // Try to place the rectangle in upright (non-flipped) orientation.
        if (freeRectangles[i].width >= width && freeRectangles[i].height >= height)
        {
            int leftoverHoriz = abs(freeRectangles[i].width - width);
            int leftoverVert = abs(freeRectangles[i].height - height);
            int shortSideFit = min(leftoverHoriz, leftoverVert);
            int longSideFit = max(leftoverHoriz, leftoverVert);

            if (shortSideFit < bestShortSideFit || (shortSideFit == bestShortSideFit && longSideFit < bestLongSideFit))
            {
                bestNode.x = freeRectangles[i].x;
                bestNode.y = freeRectangles[i].y;
                bestNode.width = width;
                bestNode.height = height;
                bestShortSideFit = shortSideFit;
                bestLongSideFit = longSideFit;
            }
        }

        if (freeRectangles[i].width >= height && freeRectangles[i].height >= width)
        {
            int flippedLeftoverHoriz = abs(freeRectangles[i].width - height);
            int flippedLeftoverVert = abs(freeRectangles[i].height - width);
            int flippedShortSideFit = min(flippedLeftoverHoriz, flippedLeftoverVert);
            int flippedLongSideFit = max(flippedLeftoverHoriz, flippedLeftoverVert);

            if (flippedShortSideFit < bestShortSideFit || (flippedShortSideFit == bestShortSideFit && flippedLongSideFit < bestLongSideFit))
            {
                bestNode.x = freeRectangles[i].x;
                bestNode.y = freeRectangles[i].y;
                bestNode.width = height;
                bestNode.height = width;
                bestShortSideFit = flippedShortSideFit;
                bestLongSideFit = flippedLongSideFit;
            }
        }
    }
    return bestNode;
}

Rect MaxRectsBinPack::FindPositionForNewNodeBestLongSideFit(int width, int height,
    int &bestShortSideFit, int &bestLongSideFit) const
{
    Rect bestNode;
    memset(&bestNode, 0, sizeof(Rect));

    bestLongSideFit = std::numeric_limits<int>::max();

    for(size_t i = 0; i < freeRectangles.size(); ++i)
    {
        // Try to place the rectangle in upright (non-flipped) orientation.
        if (freeRectangles[i].width >= width && freeRectangles[i].height >= height)
        {
            int leftoverHoriz = abs(freeRectangles[i].width - width);
            int leftoverVert = abs(freeRectangles[i].height - height);
            int shortSideFit = min(leftoverHoriz, leftoverVert);
            int longSideFit = max(leftoverHoriz, leftoverVert);

            if (longSideFit < bestLongSideFit || (longSideFit == bestLongSideFit && shortSideFit < bestShortSideFit))
            {
                bestNode.x = freeRectangles[i].x;
                bestNode.y = freeRectangles[i].y;
                bestNode.width = width;
                bestNode.height = height;
                bestShortSideFit = shortSideFit;
                bestLongSideFit = longSideFit;
            }
        }

        if (freeRectangles[i].width >= height && freeRectangles[i].height >= width)
        {
            int leftoverHoriz = abs(freeRectangles[i].width - height);
            int leftoverVert = abs(freeRectangles[i].height - width);
            int shortSideFit = min(leftoverHoriz, leftoverVert);
            int longSideFit = max(leftoverHoriz, leftoverVert);

            if (longSideFit < bestLongSideFit || (longSideFit == bestLongSideFit && shortSideFit < bestShortSideFit))
            {
                bestNode.x = freeRectangles[i].x;
                bestNode.y = freeRectangles[i].y;
                bestNode.width = height;
                bestNode.height = width;
                bestShortSideFit = shortSideFit;
                bestLongSideFit = longSideFit;
            }
        }
    }
    return bestNode;
}

Rect MaxRectsBinPack::FindPositionForNewNodeBestAreaFit(int width, int height,
    int &bestAreaFit, int &bestShortSideFit) const
{
    Rect bestNode;
    memset(&bestNode, 0, sizeof(Rect));

    bestAreaFit = std::numeric_limits<int>::max();

    for(size_t i = 0; i < freeRectangles.size(); ++i)
    {
        int areaFit = freeRectangles[i].width * freeRectangles[i].height - width * height;

        // Try to place the rectangle in upright (non-flipped) orientation.
        if (freeRectangles[i].width >= width && freeRectangles[i].height >= height)
        {
            int leftoverHoriz = abs(freeRectangles[i].width - width);
            int leftoverVert = abs(freeRectangles[i].height - height);
            int shortSideFit = min(leftoverHoriz, leftoverVert);

            if (areaFit < bestAreaFit || (areaFit == bestAreaFit && shortSideFit < bestShortSideFit))
            {
                bestNode.x = freeRectangles[i].x;
                bestNode.y = freeRectangles[i].y;
                bestNode.width = width;
                bestNode.height = height;
                bestShortSideFit = shortSideFit;
                bestAreaFit = areaFit;
            }
        }

        if (freeRectangles[i].width >= height && freeRectangles[i].height >= width)
        {
            int leftoverHoriz = abs(freeRectangles[i].width - height);
            int leftoverVert = abs(freeRectangles[i].height - width);
            int shortSideFit = min(leftoverHoriz, leftoverVert);

            if (areaFit < bestAreaFit || (areaFit == bestAreaFit && shortSideFit < bestShortSideFit))
            {
                bestNode.x = freeRectangles[i].x;
                bestNode.y = freeRectangles[i].y;
                bestNode.width = height;
                bestNode.height = width;
                bestShortSideFit = shortSideFit;
                bestAreaFit = areaFit;
            }
        }
    }
    return bestNode;
}

/// Returns 0 if the two intervals i1 and i2 are disjoint, or the length of their overlap otherwise.
int CommonIntervalLength(int i1start, int i1end, int i2start, int i2end)
{
    if (i1end < i2start || i2end < i1start)
        return 0;
    return min(i1end, i2end) - max(i1start, i2start);
}

int MaxRectsBinPack::ContactPointScoreNode(int x, int y, int width, int height) const
{
    int score = 0;

    if (x == 0 || x + width == binWidth)
        score += height;
    if (y == 0 || y + height == binHeight)
        score += width;

    for(size_t i = 0; i < usedRectangles.size(); ++i)
    {
        if (usedRectangles[i].x == x + width || usedRectangles[i].x + usedRectangles[i].width == x)
            score += CommonIntervalLength(usedRectangles[i].y, usedRectangles[i].y + usedRectangles[i].height, y, y + height);
        if (usedRectangles[i].y == y + height || usedRectangles[i].y + usedRectangles[i].height == y)
            score += CommonIntervalLength(usedRectangles[i].x, usedRectangles[i].x + usedRectangles[i].width, x, x + width);
    }
    return score;
}

Rect MaxRectsBinPack::FindPositionForNewNodeContactPoint(int width, int height, int &bestContactScore) const
{
    Rect bestNode;
    memset(&bestNode, 0, sizeof(Rect));

    bestContactScore = -1;

    for(size_t i = 0; i < freeRectangles.size(); ++i)
    {
        // Try to place the rectangle in upright (non-flipped) orientation.
        if (freeRectangles[i].width >= width && freeRectangles[i].height >= height)
        {
            int score = ContactPointScoreNode(freeRectangles[i].x, freeRectangles[i].y, width, height);
            if (score > bestContactScore)
            {
                bestNode.x = freeRectangles[i].x;
                bestNode.y = freeRectangles[i].y;
                bestNode.width = width;
                bestNode.height = height;
                bestContactScore = score;
            }
        }
        if (freeRectangles[i].width >= height && freeRectangles[i].height >= width)
        {
            int score = ContactPointScoreNode(freeRectangles[i].x, freeRectangles[i].y, height, width);
            if (score > bestContactScore)
            {
                bestNode.x = freeRectangles[i].x;
                bestNode.y = freeRectangles[i].y;
                bestNode.width = height;
                bestNode.height = width;
                bestContactScore = score;
            }
        }
    }
    return bestNode;
}

bool MaxRectsBinPack::SplitFreeNode(Rect freeNode, const Rect &usedNode)
{
    // Test with SAT if the rectangles even intersect.
    if (usedNode.x >= freeNode.x + freeNode.width || usedNode.x + usedNode.width <= freeNode.x ||
        usedNode.y >= freeNode.y + freeNode.height || usedNode.y + usedNode.height <= freeNode.y)
        return false;

    if (usedNode.x < freeNode.x + freeNode.width && usedNode.x + usedNode.width > freeNode.x)
    {
        // New node at the top side of the used node.
        if (usedNode.y > freeNode.y && usedNode.y < freeNode.y + freeNode.height)
        {
            Rect newNode = freeNode;
            newNode.height = usedNode.y - newNode.y;
            freeRectangles.push_back(newNode);
        }

        // New node at the bottom side of the used node.
        if (usedNode.y + usedNode.height < freeNode.y + freeNode.height)
        {
            Rect newNode = freeNode;
            newNode.y = usedNode.y + usedNode.height;
            newNode.height = freeNode.y + freeNode.height - (usedNode.y + usedNode.height);
            freeRectangles.push_back(newNode);
        }
    }

    if (usedNode.y < freeNode.y + freeNode.height && usedNode.y + usedNode.height > freeNode.y)
    {
        // New node at the left side of the used node.
        if (usedNode.x > freeNode.x && usedNode.x < freeNode.x + freeNode.width)
        {
            Rect newNode = freeNode;
            newNode.width = usedNode.x - newNode.x;
            freeRectangles.push_back(newNode);
        }

        // New node at the right side of the used node.
        if (usedNode.x + usedNode.width < freeNode.x + freeNode.width)
        {
            Rect newNode = freeNode;
            newNode.x = usedNode.x + usedNode.width;
            newNode.width = freeNode.x + freeNode.width - (usedNode.x + usedNode.width);
            freeRectangles.push_back(newNode);
        }
    }

    return true;
}

void MaxRectsBinPack::PruneFreeList()
{
    /*
    ///  Would be nice to do something like this, to avoid a Theta(n^2) loop through each pair.
    ///  But unfortunately it doesn't quite cut it, since we also want to detect containment.
    ///  Perhaps there's another way to do this faster than Theta(n^2).

    if (freeRectangles.size() > 0)
        clb::sort::QuickSort(&freeRectangles[0], freeRectangles.size(), NodeSortCmp);

    for(size_t i = 0; i < freeRectangles.size()-1; ++i)
        if (freeRectangles[i].x == freeRectangles[i+1].x &&
            freeRectangles[i].y == freeRectangles[i+1].y &&
            freeRectangles[i].width == freeRectangles[i+1].width &&
            freeRectangles[i].height == freeRectangles[i+1].height)
        {
            freeRectangles.erase(freeRectangles.begin() + i);
            --i;
        }
    */

    /// Go through each pair and remove any rectangle that is redundant.
    for(size_t i = 0; i < freeRectangles.size(); ++i)
        for(size_t j = i+1; j < freeRectangles.size(); ++j)
        {
            if (IsContainedIn(freeRectangles[i], freeRectangles[j]))
            {
                freeRectangles.erase(freeRectangles.begin()+i);
                --i;
                break;
            }
            if (IsContainedIn(freeRectangles[j], freeRectangles[i]))
            {
                freeRectangles.erase(freeRectangles.begin()+j);
                --j;
            }
        }
}

}

using namespace rbp;

typedef vector<rbp::RectSize> RectSizeVector;
typedef vector<rbp::RectSize>::iterator RectSizeVectorIterator;
typedef vector<rbp::Rect> RectVector;
typedef vector<rbp::Rect>::iterator RectVectorIterator;

#include <cstdio>
#include <cstdlib>
#include <cstddef> // offsetof

extern "C" {
    #include "MaxRect.h"
    void lychee_maxRect(int *, int *, struct RectInfo *, int);
}
void sortBinResult(struct Bin * bin);

void removePackedItem(int sizeId, RectSizeVector &rsv);

static int PACK_RECT_ONE_BY_ONE = 1;

void c_minimizeBins(struct Size * max_bin_size,
        struct Size * sizes, int len_size,
        struct Bin ** bin_result, int * bin_size) {
    int maxBinWidth = max_bin_size->width;
    int maxBinHeight = max_bin_size->height;
    RectSizeVector remain_sizes;

    for(int i = 0; i < len_size; i++) {
        RectSize rs;
        rs.width = sizes[i].width;
        rs.height = sizes[i].height;
        rs.sizeId = i; // 以数组索引初始化size_id
        remain_sizes.push_back(rs);
    }

    size_t packed_rect_count = 0;
    std::vector<struct Bin> vec_bin;

    while(packed_rect_count < len_size) {
        // 设置输入参数
        RectSizeVector rsv;
        rsv = remain_sizes;

        MaxRectsBinPack bin;
        bin.Init(maxBinWidth, maxBinHeight);
        MaxRectsBinPack::FreeRectChoiceHeuristic heuristic;
        heuristic = MaxRectsBinPack::RectBottomLeftRule;

        RectVector rv; // 结果
        if (PACK_RECT_ONE_BY_ONE) {
            RectSizeVectorIterator it = rsv.begin();
            for ( ; it != rsv.end(); ++it) {
                Rect rc = bin.Insert(it->width, it->height, it->sizeId, heuristic);
                if (rc.height == 0) {
                    continue;
                }
                rv.push_back(rc);
            }
        } else {
            bin.Insert(rsv, rv, heuristic);
        }

        // 更新已pack总数
        packed_rect_count += rv.size();
        struct Bin cbin;
        cbin.width = maxBinWidth;
        cbin.height = maxBinHeight;
        cbin.itemCount = rv.size();
        cbin.itemPos = (struct RectInfo *)malloc(
                sizeof(struct RectInfo) * cbin.itemCount);
        vec_bin.push_back(cbin);

        struct RectInfo * ri = cbin.itemPos;
        RectVectorIterator it = rv.begin();
        int i = 0;
        for(; it != rv.end(); ++it, i++) {
            ri[i].x         = it->x;
            ri[i].y         = it->y;
            ri[i].width     = it->width;
            ri[i].height    = it->height;
            ri[i].isRotated = it->isR;
            ri[i].sizeId    = it->sizeId;
            removePackedItem(it->sizeId, remain_sizes);
        }
        sortBinResult(&cbin);
    }

    int rb_size = vec_bin.size();
    *bin_result = (struct Bin *) malloc(sizeof(struct Bin) * rb_size);
    *bin_size = rb_size;
    struct Bin * rs = *bin_result;
    for(int i = 0; i < rb_size; i++) {
        //rs[i] = vec_bin[i]; // use = op, not so C style ;-)
        rs[i].width = vec_bin[i].width;
        rs[i].height = vec_bin[i].height;
        rs[i].itemCount = vec_bin[i].itemCount;
        rs[i].itemPos = vec_bin[i].itemPos;
    }
}

void removePackedItem(int sizeId, RectSizeVector &rsv) {
    std::vector<rbp::RectSize>::iterator it = rsv.begin();
    for (; it != rsv.end(); ++it) {
        if(it->sizeId == sizeId) {
            rsv.erase(it);
            return;
        }
    }
}

void c_freeBinResult(struct Bin * bin, int len) {
    for(int i = 0; i < len; i++) {
        if (bin[i].itemPos) free(bin[i].itemPos);
        //printf("free pos addr: %p\n", bin[i].itemPos);
    }
    free(bin);
}

// 从ri中读数据,初始化size数组
void fillRectSize(struct RectInfo *ri, int len, RectSizeVector &r) {
    r.clear();
    for (int i = 0; i < len; ++i) {
        RectSize rs;
        rs.width = ri[i].width;
        rs.height = ri[i].height;
        r.push_back(rs);
    }
}

//找到一个之后,就在rv中删除, 然后设置r的x y和旋转
bool findRectInfoBySize(RectVector &rv, struct RectInfo &r) {
    RectVectorIterator it = rv.begin();
    for (; it != rv.end(); ++it) {
        // 处理翻转
        if (it->width == r.width && it->height == r.height) {
            r.x = it->x;
            r.y = it->y;
            r.isRotated = 0;

            rv.erase(it);
            return true;
        }
        if (it->width == r.height && it->height == r.width) {
            r.x = it->x;
            r.y = it->y;
            r.isRotated = 1;

            rv.erase(it);
            return true;
        }
    }
    return false;
}

// to Haskell 的C API
int maxRect(struct Size * size, int len_size, struct Position * pos,
        int * w, int * h) {
    if (len_size < 0) return -1;
    struct RectInfo * v = (struct RectInfo *)malloc(sizeof(*v) * len_size);
    for (int i = 0; i < len_size; ++i) {
        v[i].width  = size[i].width;
        v[i].height = size[i].height;
    }
    lychee_maxRect(w, h, v, len_size);
    for (int i = 0; i < len_size; ++i) {
        pos[i].x = v[i].x;
        pos[i].y = v[i].y;
        pos[i].isRotated = v[i].isRotated;
    }
    free(v);
    return 521;
}

//把一组size pack到一个bin中, 如果bin不够大则一直增大bin直到能够放下所有size
void lychee_maxRect(int * width, int * height, struct RectInfo * ra, int n) {
    int w = 512, h = 512; // 初始bin大小
    for(;;) {
        RectSizeVector rsv; // width height 输入参数 要摆放的一组size

        fillRectSize(ra, n, rsv); // 前几天把这里改错了,rsv每次都会被更新的,需要
        //重新初始化
        MaxRectsBinPack bin;
        bin.Init(w, h);
        MaxRectsBinPack::FreeRectChoiceHeuristic heuristic;
        heuristic = MaxRectsBinPack::RectBottomLeftRule;

        RectVector rv; // 计算结果 放进bin中的一组位置和size size可能被翻转
        bin.Insert(rsv, rv, heuristic);

        //如果没有把全部的rect pack进去,则增加bin的size, 继续pack
        if (rv.size() == n) {
            for (int i = 0; i < n; ++i) findRectInfoBySize(rv, ra[i]);
            *width = w, *height = h;
            return;
        } else if(rv.size() < n) {
            static bool inc_width = false;
            if (inc_width) w *= 2; else h *= 2;
            inc_width = ! inc_width;
        }
    }
}

struct Size size_list[] = {
    {32, 32},
    {16, 32},
    {64, 16},
    {64, 32},
    {16, 16}
};

struct Size size_list_2[] = {
        {226, 60}
    ,   {34 ,30}
    ,   {138 ,38}
    ,   {114, 202}
    ,   {40, 170}
    ,   {126, 50}
    ,   {262, 52}
    ,   {116, 138}
    ,   {114, 162}
    ,   {158, 108}
    ,   {144, 118}
    ,   {144, 100}
    ,   {126, 74}
    ,   {176, 86}
    ,   {66, 114}
    ,   {186, 132}
    ,   {144, 178}
};

void showBinResult(struct Bin * bin_result, int bin_size) {
    printf("bin size is %d\n", bin_size);
    for (int i = 0; i < bin_size; ++i) {
        struct Bin * bin = bin_result + i;
        printf("bin %d, rects: %d\n", i, bin->itemCount);
        for (int j = 0; j < bin->itemCount; ++j) {
            struct RectInfo * ri = bin->itemPos + j;
            printf("    rect info %2d : %4d, %4d, %4d, %4d, rotated: %s\n",
                    ri->sizeId, ri->x, ri->y, ri->width, ri->height,
                    ri->isRotated ? "true" : "false");
        }
    }
}

#define Tp (const struct RectInfo *)

static int cmp_func(const void * a, const void * b) {
    return (Tp a)->sizeId - (Tp b)->sizeId;
}

void sortBinResult(struct Bin * bin) {
    qsort(bin->itemPos, bin->itemCount, sizeof(struct RectInfo), cmp_func);
}

void test_main() {
    struct Size bin_size = {1024, 1024};
    struct Bin *result;
    int bin_len;
    c_minimizeBins(&bin_size,
                   size_list, 5,
                   //size_list_2, 17,
                   &result, &bin_len);
    showBinResult(result, bin_len);
    c_freeBinResult(result, bin_len);
}


