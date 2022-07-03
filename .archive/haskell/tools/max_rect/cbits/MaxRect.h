
struct Size {
    int width, height;
};

struct Position {
    int x, y;
    int isRotated;
};

struct RectInfo {
    int x, y;          // 在bin中的位置
    int width, height; // size
    int isRotated;     // 是否被旋转
    int sizeId;        // 对应的输入array中的size的index
};

// sizeof 24
// offsetof 0 4 8 16
struct Bin {
    int width;
    int height;
    int itemCount;
    struct RectInfo * itemPos; // 必须初始化为NULL或有效指针地址
};

int maxRect(struct Size * size, int len_size, struct Position * pos,
        int * w, int * h);

void c_minimizeBins
    ( struct Size * max_bin_size // 输入参数 最大bin size
    , struct Size * sizes        // 输入参数 要pack的size列表
    , int           len_size     // 输入参数 size列表的长度
    , struct Bin ** bin_result   // 输出参数 bin 列表 由调用者释放内存
    , int *         bin_size     // 输出参数 bin 列表长度
    );

void c_freeBinResult(struct Bin * bin, int len);
