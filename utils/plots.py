import matplotlib.pyplot as plt
import numpy as np
from lib.ch_to_pol import ch_to_pol
from lib.pol_to_cart import pol_to_cart

"""
all kinds of plots
"""


def plot_setup(array, sources, cpt_pts, room):
    """
    Plots the geometric setup of the room, microphone array, and sources.

    Parameters:
    ----------
    array : Microphone array object containing position and other info.
    source : Source object containing position, coefficients, and orientation.
    cpt_pts : CPT object containing positions of control points (vms).
    room : Room object containing dimensions.
    """
    print("Plotting setup...")

    plt.figure(1)

    # Draw room
    plt.Rectangle((0, 0), room['dim'][0], room['dim'][1], linewidth=1)

    # Draw sources
    s_pos = sources['position']
    for i_src in range(sources['N']):
        plt.scatter(s_pos[i_src + 1][0], s_pos[i_src + 1][1], s=50, color='red', marker='D', facecolors='none')

        tt, rr = ch_to_pol(180, np.array(sources['coefficient'][i_src + 1]), sources['orientation'][i_src + 1][0])
        x_patt, y_patt = pol_to_cart(tt, abs(rr * 0.5))
        plt.plot(x_patt + s_pos[i_src + 1][0], y_patt + s_pos[i_src + 1][1], color='red', linewidth=1.5)

    # Draw real microphones
    for aa in range(array['N']):
        tmp = array['positions'][aa]
        for mm in range(array['micN']):
            plt.scatter(tmp[mm, 0], tmp[mm, 1], s=30, color='blue', marker='o', facecolors='none')

    # Draw virtual microphones
    plt.scatter(cpt_pts['positions'][:, 0], cpt_pts['positions'][:, 1], s=50, color='k', marker='s', facecolors='none')

    plt.grid(True)
    plt.axis('equal')
    plt.xlabel('x [m]')
    plt.ylabel('y [m]')
    plt.title('Geometric setup')
    plt.show()


def plot_stft(stft, ff, tt):
    # Plot the magnitude of the STFT
    plt.figure(figsize=(10, 6))
    plt.pcolormesh(tt, ff, np.abs(stft), shading='gouraud')
    plt.title('STFT Magnitude')
    plt.ylabel('Frequency [Hz]')
    plt.xlabel('Time [sec]')
    plt.colorbar(label='Magnitude')
    plt.show()


def plot_istft(istft, tt):
    # Plot the rebuilt time signal
    plt.figure(figsize=(10, 6))
    plt.plot(tt, istft, linewidth=0.5)
    plt.title('Rebuilt signal')
    plt.ylabel('Amplitude')
    plt.xlabel('Time [sec]')
    plt.grid(True)
    plt.show()


def plot_signal_in_time(signal, t_ax, title):
    plt.plot(t_ax, signal, linewidth=0.5)
    plt.xlabel('Time (s)')
    plt.ylabel('Amplitude')
    plt.title(title)
    plt.grid(True)
    plt.show()


def plot_rirs_time(rir_time, room, source, title):
    rir_time = np.reshape(rir_time, (rir_time.shape[1]))

    # Create the time axis
    time_conversion_k = source['signalLength']/len(rir_time)
    time_axis_sec = np.arange(0, source['signalLength'], time_conversion_k)

    plt.plot(time_axis_sec, rir_time, linewidth=0.5)
    plt.xlabel('Time (s)')
    plt.ylabel('Amplitude')
    plt.title(title)
    plt.axvline(x=room['T60'], color='red', linestyle='--', label='T60')
    plt.grid(True)
    plt.show()


def plot_rirs_stft(rir_stft, title):

    fig, ax = plt.subplots()
    ax.imshow(np.abs(rir_stft), origin='lower', aspect='auto')
    fig.suptitle(title)
    plt.show()


def debug_get_array_signals(macro, source, room, rir_time, arraySTFT, h_time, arrayDirectSTFT, i_src, aa, mm):
    if macro['PRINT_GROUND_RIR_TIME']:
        plot_rirs_time(rir_time, room, source,
                       f"Ground time RIR of source {i_src + 1}, array {aa + 1}, mic {mm + 1}")

    if macro['PRINT_GROUND_arraySTFT']:
        plot_rirs_stft(arraySTFT[aa, mm, :, :],
                       f"Convolved ground stft RIR of source {i_src + 1}, array {aa + 1}, mic {mm + 1}")

    if macro['PRINT_GROUND_H_TIME']:
        plot_rirs_time(h_time, room, source,
                       f"Ground time Dir Path of source {i_src + 1}, array {aa + 1}, mic {mm + 1}")

    if macro['PRINT_GROUND_arrayDirectSTFT']:
        plot_rirs_stft(arrayDirectSTFT[aa, mm, :, :],
                       f"Convolved ground stft Dir Path of source {i_src + 1}, array {aa + 1}, mic {mm + 1}")


def debug_get_reference_signals(macro, source, room, rir_time, testCompleteSTFT, h_time, testDirectSTFT, i_src, vm):
    if macro['PRINT_GROUND_VM_RIR_TIME']:
        plot_rirs_time(rir_time, room, source,
                       f"Ground time RIR of source {i_src + 1}, virtual mic {vm + 1}")

    if macro['PRINT_GROUND_testCompleteSTFT']:
        plot_rirs_stft(testCompleteSTFT[vm, :, :],
                       f"Convolved ground stft RIR of source {i_src + 1}, virtual mic {vm + 1}")

    if macro['PRINT_GROUND_VM_H_TIME']:
        plot_rirs_time(h_time, room, source,
                       f"Ground time Dir Path of source {i_src + 1}, virtual mic {vm + 1}")

    if macro['PRINT_GROUND_testDirectSTFT']:
        plot_rirs_stft(testDirectSTFT[vm, :, :],
                       f"Convolved ground stft Dir Path of source {i_src + 1}, virtual mic {vm + 1}")
