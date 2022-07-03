package cmd

import (
	"fmt"
	"image"
	"image/color"
	"image/gif"
	"io"
	"log"
	"math"
	"math/rand"
	"net/http"
	"time"

	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(imageCmd)
	imageCmd.Flags().BoolVarP(&serveHttp, "serve", "s", false, "")
}

var serveHttp = false

var imageCmd = &cobra.Command{
	Use:   "image",
	Short: "run image processing sample",
	Run: func(cmd *cobra.Command, args []string) {
		rand.Seed(time.Now().UTC().UnixNano())

		if serveHttp {
			addr := "localhost:8000"
			fmt.Println("listening on: ", addr)
			handlerGIF := func(w http.ResponseWriter, r *http.Request) {
				lissajous(w)
			}
			handlerSVG := func(w http.ResponseWriter, r *http.Request) {
				w.Header().Set("content-type", "image/svg+xml")
				svgSample(w)
			}
			http.HandleFunc("/", handlerGIF)
			http.HandleFunc("/svg", handlerSVG)
			log.Fatal(http.ListenAndServe(addr, nil))
		} else {
			fmt.Println(";-)")
			// svgSample(os.Stdout)
			// lissajous(os.Stdout)
		}

	},
}

var palette = []color.Color{color.Black, color.White, color.RGBA{G: 255, A: 255}}

func lissajous(out io.Writer) {
	const (
		cycles  = 5
		res     = 0.0001
		size    = 100
		nframes = 100
		delay   = 2
	)
	freq := rand.Float64() * 3.0
	anim := gif.GIF{LoopCount: nframes}
	phase := 0.0
	for i := 0; i < nframes; i++ {
		rect := image.Rect(0, 0, 2*size+1, 2*size+1)
		img := image.NewPaletted(rect, palette)
		for t := 0.0; t < cycles*2*math.Pi; t += res {
			x := math.Sin(t)
			y := math.Sin(t*freq + phase)
			img.SetColorIndex(size+int(x*size+0.5), size+int(y*size+0.5), 2)
		}
		phase += 0.1
		anim.Delay = append(anim.Delay, delay)
		anim.Image = append(anim.Image, img)

	}
	gif.EncodeAll(out, &anim)
}

const (
	width, height = 600, 320
	cells         = 100
	xyrange       = 30.0
	xyscale       = width / 2 / xyrange
	zscale        = height * 0.4
	angle         = math.Pi / 6
)

var sin32, cos30 = math.Sin(angle), math.Cos(angle)

func svgSample(out io.Writer) {
	fmt.Fprintf(out, "<svg xmlns='http://www.w3.org/2000/svg' "+
		"style='stroke: grey; fill: white; stroke-width: 0.7' "+
		"width='%d' height='%d' >\n", width, height)
	for i := 0; i < cells; i++ {
		for j := 0; j < cells; j++ {
			ax, ay := corner(i+1, j)
			bx, by := corner(i, j)
			cx, cy := corner(i, j+1)
			dx, dy := corner(i+1, j+1)
			fmt.Fprintf(out, "<polygon points='%g,%g %g,%g %g,%g %g,%g' />\n",
				ax, ay, bx, by, cx, cy, dx, dy)
		}
	}
	fmt.Fprintln(out, "</svg>")

}

func corner(i, j int) (float64, float64) {
	x := xyrange * (float64(i)/cells - 0.5)
	y := xyrange * (float64(j)/cells - 0.5)

	z := f(x, y)

	sx := width/2 + (x-y)*cos30*xyscale
	sy := height/2 + (x+y)*sin32*xyscale - z*zscale
	return sx, sy
}

func f(x, y float64) float64 {
	r := math.Hypot(x, y)
	return math.Sin(r) / r
}
