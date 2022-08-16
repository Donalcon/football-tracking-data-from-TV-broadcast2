import time
import argparse
# from Detect_and_Track.demo_detection import detect_demo
# from Detect_and_Track.demo_tracking import track_demo
# from projection_2D.demo_mapping import demo_mapping
from Detect_and_Track.get_init_data import get_init_data
from projection_2D.get_tracking_data import get_tracking_data

parser = argparse.ArgumentParser(add_help=False)
parser.add_argument("--input", default='./Data/test.mp4', type=str,
                        help="the input video filename")
parser.add_argument("--output", default='out', type=str,
                        help="the output filename prefix")
args = parser.parse_args()

# ii, c = detect_demo('./Data/Capture.JPG')
# track_demo('./Data/test3_0.mp4', out_name = 'demo')
# demo_mapping('./Data/Capture.JPG')
start = time.time()
init_df = get_init_data(args.input, args.output, ['red', 'green', 'black', None, 'yellow', 'white'])
init_df.head()
initialize_time = time.time()
tracking_df = get_tracking_data('./Out/%s_init_df.csv' % args.output, './Out/%s_out.mp4' % args.output, '%s_final' % args.output, test=True, sample_step=30)
tracking_time = time.time()
print('Initialization time: %s seconds' % (initialize_time - start))
print('Tracking time: %s seconds' % (tracking_time - initialize_time))
print('Total time usage: %s seconds' % (tracking_time - start))