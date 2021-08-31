###
#  generate pixel matrix (grayscale) and pencil black sketch drawing
#    for punkverse - punk universe encyclopedia

$LOAD_PATH.unshift( "../cryptopunks/lib" )
require 'cryptopunks'




### todo/fix - move/add to pixelart gem
module Pixelart
  class Image
    def sketch( sketch=4, line: 1 )
       # todo: line - find a better name eg. line_strenght/width or such?
      width  = @img.width*sketch  + (@img.width+1)*line
      height = @img.height*sketch + (@img.height+1)*line

      puts "  #{width}x#{height}"

      img = Image.new( width, height, Color::WHITE )

      @img.width.times do |x|
        @img.height.times do |y|
          pixel = @img[x,y]

          ## get surrounding pixels - if "out-of-bound" use transparent (0)
          left   =  x == 0  ? Color::TRANSPARENT : @img[x-1,y]
          top    =  y == 0  ? Color::TRANSPARENT : @img[x  ,y-1]

          if pixel != left   ## draw vertical line
              (sketch+line*2).times do |n|
                line.times do |m|
                  img[    x*sketch + line*x + m,
                      n + y*sketch + line*y] = Color::BLACK
                end
              end
          end

          if pixel != top   ## draw horizontal line
             (sketch+line*2).times do |n|
               line.times do |m|
                 img[n + x*sketch + line*x,
                         y*sketch + line*y + m] = Color::BLACK
                end
             end
          end


          ## check special edge case for x and y to add "finish-up" right and bottom line
          if x == @img.width-1 && pixel != Color::TRANSPARENT
             ## draw vertical line
             (sketch+line*2).times do |n|
              line.times do |m|
                img[    (x+1)*sketch + line*(x+1) + m,
                    n + y*sketch + line*y] = Color::BLACK
              end
             end
          end

          if y== @img.height-1 && pixel != Color::TRANSPARENT
            ## draw horizontal line
            (sketch+line*2).times do |n|
              line.times do |m|
                img[n + x*sketch + line*x,
                        (y+1)*sketch + line*(y+1) + m] = Color::BLACK
              end
            end
          end
        end
      end

      img
  end


  ## todo: find a better name e.g design draft / outline/ ??? or such - why? why not?
  def design_spec( zoom=3, spacing: 1, transparent: nil )

    grayscale_img = @img.grayscale   ## step 1 - convert to grayscale 0-255 shades of gray

    # todo: line - find a better name eg. line_strenght/width or such?
    width  = grayscale_img.width*zoom  + (grayscale_img.width-1)*spacing
    height = grayscale_img.height*zoom + (grayscale_img.height-1)*spacing

    puts "  #{width}x#{height}"

    img = Image.new( width, height, Color::WHITE )

    grayscale_img.width.times do |x|
      grayscale_img.height.times do |y|
        pixel = grayscale_img[x,y]

        if transparent && pixel == Color::TRANSPARENT   ## draw something for transparent?
          pixel = Color.from_hex( '#D3D3D3' )  # lightgray
          offset = (zoom-transparent)/2  ## center in "zoom" canvas (assumes transparent < zoom)
          transparent.times do |n|
            transparent.times do |m|
              img[offset + x*zoom+n + spacing*x,
                  offset + y*zoom+m + spacing*y] = pixel
            end
          end
        else
          pixel = Color::WHITE   if pixel == Color::TRANSPARENT
          zoom.times do |n|
            zoom.times do |m|
              img[x*zoom+n + spacing*x,
                  y*zoom+m + spacing*y] = pixel
            end
          end
        end
      end
    end
    img
  end
end # class Image
end # module Pixelart



## pre-define some (standard) colors (in rgb hex)
BLACK = '000000'
WHITE = 'FFFFFF'



design =<<TXT
. . . . . . . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . . . . . . .
. . . . . . . . . . . . . . . . . . . . . . . .
. . . . . . . . @ @ @ @ @ @ @ . . . . . . . . .
. . . . . . . @ ^ ^ ^ ^ ^ ^ ^ @ . . . . . . . .
. . . . . . @ ^ ^ ~ ^ ^ ^ ^ ^ ^ @ . . . . . . .
. . . . . . @ ^ ~ ^ ^ ^ ^ ^ ^ ^ @ . . . . . . .
. . . . . . @ ^ ^ ^ ^ ^ ^ ^ ^ ^ @ . . . . . . .
. . . . . . @ ^ ^ ^ ^ ^ ^ ^ ^ ^ @ . . . . . . .
. . . . . . @ ^ ^ x x ^ ^ ^ x x @ . . . . . . .
. . . . . @ ^ ^ ^ @ o ^ ^ ^ @ o @ . . . . . . .
. . . . . @ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ @ . . . . . . .
. . . . . @ @ ^ ^ ^ ^ ^ ^ ^ ^ ^ @ . . . . . . .
. . . . . . @ ^ ^ ^ ^ ^ @ @ ^ ^ @ . . . . . . .
. . . . . . @ ^ ^ ^ ^ ^ ^ ^ ^ ^ @ . . . . . . .
. . . . . . @ ^ ^ ^ ^ ^ ^ ^ ^ ^ @ . . . . . . .
. . . . . . @ ^ ^ ^ ^ @ @ @ ^ ^ @ . . . . . . .
. . . . . . @ ^ ^ ^ ^ ^ ^ ^ ^ ^ @ . . . . . . .
. . . . . . @ ^ ^ ^ ^ ^ ^ ^ ^ @ . . . . . . . .
. . . . . . @ ^ ^ ^ @ @ @ @ @ . . . . . . . . .
. . . . . . @ ^ ^ ^ @ . . . . . . . . . . . . .
. . . . . . @ ^ ^ ^ @ . . . . . . . . . . . . .
TXT

pp HUMAN_COLORS['light']

punk = Image.parse( design, colors: HUMAN_COLORS['light'] )
punk.save( "tmp/punk.png" )
punk.zoom(8).save( "tmp/punk8x.png" )



punk_sketch = punk.sketch( 8, line: 2 )
punk_sketch.save( 'tmp/punk_sketch8x2.png' )

punk_spec   = punk.design_spec( 8, spacing: 2, transparent: 2 )
punk_spec.save( 'tmp/punk_spec8x2.png' )



def calc_color_usage( punk )
  ##  calculate color histogram / usage by pixel
  usage = Hash.new(0)
  punk.pixels.each do |pixel|
    next if pixel == Color::TRANSPARENT
    usage[ pixel ] += 1
  end
  usage
end


puts "specs:"
puts  "  #{punk.width} x #{punk.height} width x height"


punk_grayscale = punk.grayscale
usage = calc_color_usage( punk_grayscale )
## pp usage

## note: assume transparent (0) is always present for now
usage_count = usage.reduce(0) { |total, (color,count)| total += count; total }
puts  "  #{usage_count} of #{punk.width*punk.height} pixels"
puts  "  #{usage.size} color(s):"


## number colors - by darkness to lightness (color 1, color 2, )

## note: black - 000, white - fff
usage_sorted = usage.sort do |l,r|
                               res =  r[1] <=> l[1]               # first by count reversed
                               res =  r[0] <=> l[0]  if res == 0  # second by black-ness/white-ness (darker/lighter)
                               res
                          end
pp usage_sorted


puts
puts "bye"

