import matlab.engine


def main() -> None:
    """ Test script for parametric virtual miking"""

    print("Launching...")
    eng = matlab.engine.start_matlab()
    eng.eval("run('parametric_vm/demo_parametric_vm.m')", nargout=0)


if __name__ == '__main__':
    main()
