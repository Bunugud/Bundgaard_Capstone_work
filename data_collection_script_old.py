import csv
import time
from pynq import MMIO

# Define AXI GPIO Base Address (Check Vivado Address Editor)
AXI_GPIO_BASE = 0x41200000  # Replace with your actual base address
REGISTER_SIZE = 0x1000  # 4 KB memory space

# Create MMIO instance for register access
mmio = MMIO(AXI_GPIO_BASE, REGISTER_SIZE)

# CSV File Path
CSV_FILE = "/home/xilinx/register_log.csv"

# Define column headers
HEADER = ["time (s)", "bit 0", "bit 1", "bit 2", "bit 3", "bit 4", "bit 5", "btn0", "btn1", "btn2", "btn3"]

# Open CSV file for writing
with open(CSV_FILE, mode="w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(HEADER)  # Write CSV header

    print("Logging register data every 100µs... Press Ctrl+C to stop.")

    # Get start time (relative zero time)
    start_time = time.time()

    try:
        while True:
            # Compute relative time in seconds
            elapsed_time = time.time() - start_time

            # Read GPIO register values
            sample_data = mmio.read(0x00) & 0x3F  # Read 6-bit sample data
            btns_data = mmio.read(0x08) & 0x0F  # Read 4-bit button data

            # Convert values to individual bits
            sample_bits = [(sample_data >> i) & 1 for i in range(6)]
            btn_bits = [(btns_data >> i) & 1 for i in range(4)]

            # Write data to CSV
            writer.writerow([round(elapsed_time, 6)] + sample_bits + btn_bits)  # 6 decimal places

            # Sleep for 100µs (0.0001s)
            time.sleep(0.0001)

    except KeyboardInterrupt:
        print("\nLogging stopped. Data saved to", CSV_FILE)
