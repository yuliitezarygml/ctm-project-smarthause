/**
 * Mock API endpoint for solar panel data
 * Generates realistic fluctuating data for demonstration
 */

export default function handler(req, res) {
  // Generate realistic solar panel data with fluctuations
  const generateSolarData = () => {
    // Base values
    const basePower = 2500; // Base power in watts
    const baseVoltage = 24; // Base voltage
    const baseCurrent = 10; // Base current in amps

    // Generate fluctuations (sometimes stable, sometimes unstable)
    const stabilityFactor = Math.random();

    let power, voltage, current, efficiency, temperature;

    if (stabilityFactor > 0.7) {
      // Stable conditions
      const fluctuation = 0.05 + Math.random() * 0.1; // 5-15% fluctuation
      power = Math.round(basePower * (1 + (Math.random() * fluctuation * 2 - fluctuation)));
      voltage = Math.round(baseVoltage * (1 + (Math.random() * 0.02 * 2 - 0.02)) * 10) / 10; // 2% fluctuation
      current = Math.round(baseCurrent * (1 + (Math.random() * fluctuation * 2 - fluctuation)) * 10) / 10;
      efficiency = Math.round(85 + Math.random() * 10); // 85-95% efficiency
      temperature = Math.round(25 + Math.random() * 10); // 25-35°C
    } else {
      // Unstable conditions (clouds, partial shading, etc.)
      const fluctuation = 0.2 + Math.random() * 0.3; // 20-50% fluctuation
      power = Math.round(basePower * (1 + (Math.random() * fluctuation * 2 - fluctuation)));
      voltage = Math.round(baseVoltage * (1 + (Math.random() * 0.1 * 2 - 0.1)) * 10) / 10; // 10% fluctuation
      current = Math.round(baseCurrent * (1 + (Math.random() * fluctuation * 2 - fluctuation)) * 10) / 10;
      efficiency = Math.round(60 + Math.random() * 25); // 60-85% efficiency
      temperature = Math.round(30 + Math.random() * 15); // 30-45°C
    }

    // Ensure values don't go negative or too extreme
    power = Math.max(0, Math.min(3500, power));
    voltage = Math.max(20, Math.min(30, voltage));
    current = Math.max(0, Math.min(15, current));
    efficiency = Math.max(50, Math.min(98, efficiency));
    temperature = Math.max(20, Math.min(50, temperature));

    return {
      power: `${power} W`,
      voltage: `${voltage} V`,
      current: `${current} A`,
      efficiency: `${efficiency}%`,
      temperature: `${temperature}°C`,
      timestamp: new Date().toLocaleTimeString(),
      status: stabilityFactor > 0.7 ? 'stable' : 'fluctuating',
      condition: stabilityFactor > 0.7 ? 'Optimal sunlight' : 'Partial shading/clouds'
    };
  };

  // Generate data for the response
  const solarData = generateSolarData();

  // Add some delay to simulate real API call
  setTimeout(() => {
    res.status(200).json(solarData);
  }, 200);
}
