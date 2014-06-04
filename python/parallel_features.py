import argparse

from multiprocessing import Pool
import os
from marl import fileutils as F

NUM_CPUS = None  # Use None for system max.


def call_matlab(args):
    """Compute the CQT for a input/output file Pair.

    Parameters
    ----------
    file_pair : Pair of strings
        input_file and output file

    Returns
    -------
    Nothing, but the output file is written in this call.
    """
    os.system("./extractFeaturesForList.sh %s %s" % args)


def main(args):
    """Main routine for staging parallelization."""
    files = F.load_textlist(args.file_list)
    temp_dir = F.create_directory("tmpdir")
    temp_fmt = os.path.join(temp_dir, "deleteme-%d.txt")
    file_lists = [F.dump_textlist(files[n::args.num_cpus], temp_fmt % n)
                  for n in range(args.num_cpus)]

    pool = Pool(processes=NUM_CPUS)
    output_dir = F.create_directory(args.output_directory)
    pool.map_async(
        func=call_matlab,
        iterable=zip(file_lists, [output_dir]*args.num_cpus))
    pool.close()
    pool.join()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="")
    parser.add_argument("file_list",
                        metavar="file_list", type=str,
                        help="A text file with a list of audio filepaths.")
    parser.add_argument("output_directory",
                        metavar="output_directory", type=str,
                        help="Directory to save output arrays.")
    parser.add_argument("--num_cpus",
                        metavar="num_cpus", type=int,
                        default=6,
                        help="Number of cores to use in parallel.")
    main(parser.parse_args())
