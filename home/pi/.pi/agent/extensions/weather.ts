/**
 * Weather dashboard extension - display weather for Horben, Aeschau, Switzerland
 * Uses Open-Meteo API (no API key required)
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { DynamicBorder } from "@earendil-works/pi-coding-agent";
import { Container, Text, Spacer, matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

// Horben, Aeschau coordinates
const LAT = 46.94;
const LON = 7.55;
const LOCATION = "Horben, Aeschau, Switzerland";

interface CurrentWeather {
  temperature: number;
  windspeed: number;
  winddirection: number;
  weathercode: number;
  is_day: number;
  time: string;
}

interface HourlyData {
  time: string[];
  temperature_2m: number[];
  precipitation_probability: number[];
  weathercode: number[];
  windspeed_10m: number[];
}

interface DailyData {
  time: string[];
  weathercode: number[];
  temperature_2m_max: number[];
  temperature_2m_min: number[];
  sunrise: string[];
  sunset: string[];
  precipitation_sum: number[];
}

interface WeatherData {
  current_weather: CurrentWeather;
  hourly: HourlyData;
  daily: DailyData;
}

function weatherIcon(code: number, isDay = true): string {
  if (code === 0) return isDay ? "☀️" : "🌙";
  if (code <= 3) return isDay ? "⛅" : "☁️";
  if (code <= 48) return "🌫️";
  if (code <= 57) return "🌦️";
  if (code <= 65) return "🌧️";
  if (code <= 67) return "🧊";
  if (code <= 77) return "🌨️";
  if (code <= 82) return "🌧️";
  if (code <= 86) return "❄️";
  if (code <= 99) return "⛈️";
  return "❓";
}

function weatherDesc(code: number): string {
  if (code === 0) return "Clear sky";
  if (code === 1) return "Mainly clear";
  if (code === 2) return "Partly cloudy";
  if (code === 3) return "Overcast";
  if (code <= 48) return "Fog";
  if (code <= 55) return "Drizzle";
  if (code <= 57) return "Freezing drizzle";
  if (code <= 61) return "Light rain";
  if (code <= 63) return "Moderate rain";
  if (code <= 65) return "Heavy rain";
  if (code <= 67) return "Freezing rain";
  if (code <= 71) return "Light snow";
  if (code <= 73) return "Moderate snow";
  if (code <= 75) return "Heavy snow";
  if (code === 77) return "Snow grains";
  if (code <= 82) return "Rain showers";
  if (code <= 86) return "Snow showers";
  if (code === 95) return "Thunderstorm";
  if (code <= 99) return "Thunderstorm w/ hail";
  return "Unknown";
}

function windDirection(deg: number): string {
  const dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
  return dirs[Math.round(deg / 45) % 8];
}

function tempBar(temp: number, min: number, max: number, barWidth: number): string {
  const range = max - min || 1;
  const filled = Math.round(((temp - min) / range) * barWidth);
  const clamped = Math.max(0, Math.min(barWidth, filled));
  let color: string;
  if (temp <= 0) color = "\x1b[36m"; // cyan
  else if (temp <= 10) color = "\x1b[34m"; // blue
  else if (temp <= 20) color = "\x1b[33m"; // yellow
  else if (temp <= 30) color = "\x1b[31m"; // red
  else color = "\x1b[35m"; // magenta
  return color + "█".repeat(clamped) + "\x1b[2m" + "░".repeat(barWidth - clamped) + "\x1b[0m";
}

async function fetchWeather(): Promise<WeatherData> {
  const url = `https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current_weather=true&hourly=temperature_2m,precipitation_probability,weathercode,windspeed_10m&daily=weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,precipitation_sum&timezone=Europe/Zurich&forecast_days=7`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`API error: ${res.status}`);
  return (await res.json()) as WeatherData;
}

class WeatherDashboard {
  private data: WeatherData | null = null;
  private error: string | null = null;
  private loading = true;
  private onClose: () => void;
  private tui: { requestRender: () => void };
  private theme: any;
  private cachedLines: string[] | null = null;
  private cachedWidth = 0;

  constructor(
    tui: { requestRender: () => void },
    theme: any,
    onClose: () => void,
  ) {
    this.tui = tui;
    this.theme = theme;
    this.onClose = onClose;
    this.loadData();
  }

  private async loadData(): Promise<void> {
    try {
      this.data = await fetchWeather();
      this.loading = false;
    } catch (e: any) {
      this.error = e.message || "Failed to fetch weather";
      this.loading = false;
    }
    this.invalidate();
    this.tui.requestRender();
  }

  handleInput(data: string): void {
    if (matchesKey(data, "escape") || data === "q" || data === "Q") {
      this.onClose();
    } else if (data === "r" || data === "R") {
      this.loading = true;
      this.error = null;
      this.invalidate();
      this.tui.requestRender();
      this.loadData();
    }
  }

  invalidate(): void {
    this.cachedLines = null;
    this.cachedWidth = 0;
  }

  render(width: number): string[] {
    if (this.cachedLines && this.cachedWidth === width) {
      return this.cachedLines;
    }

    const lines: string[] = [];
    const dim = (s: string) => `\x1b[2m${s}\x1b[22m`;
    const bold = (s: string) => `\x1b[1m${s}\x1b[22m`;
    const cyan = (s: string) => `\x1b[36m${s}\x1b[0m`;
    const yellow = (s: string) => `\x1b[33m${s}\x1b[0m`;
    const green = (s: string) => `\x1b[32m${s}\x1b[0m`;
    const blue = (s: string) => `\x1b[34m${s}\x1b[0m`;
    const white = (s: string) => `\x1b[37m${s}\x1b[0m`;
    const magenta = (s: string) => `\x1b[35m${s}\x1b[0m`;

    const innerW = Math.min(width - 2, 72);
    const border = (char: string) => dim(char);
    const hLine = border("─".repeat(innerW));
    const pad = (text: string, w: number) => {
      const vw = visibleWidth(text);
      return text + " ".repeat(Math.max(0, w - vw));
    };
    const boxLine = (content: string) => {
      return truncateToWidth(border("│ ") + pad(content, innerW - 2) + border(" │"), width);
    };
    const emptyLine = () => boxLine("");

    // Top border
    lines.push(truncateToWidth(border("╭" + "─".repeat(innerW) + "╮"), width));

    // Title
    const title = `${bold(cyan("☁  Weather Dashboard"))}  ${dim("─")}  ${bold(white(LOCATION))}`;
    lines.push(boxLine(title));
    lines.push(truncateToWidth(border("├" + "─".repeat(innerW) + "┤"), width));

    if (this.loading) {
      lines.push(emptyLine());
      lines.push(boxLine(yellow("⏳ Loading weather data...")));
      lines.push(emptyLine());
    } else if (this.error) {
      lines.push(emptyLine());
      lines.push(boxLine(`\x1b[31m✗ Error: ${this.error}\x1b[0m`));
      lines.push(boxLine(dim("Press R to retry")));
      lines.push(emptyLine());
    } else if (this.data) {
      const cw = this.data.current_weather;
      const daily = this.data.daily;
      const hourly = this.data.hourly;

      // Current conditions
      const icon = weatherIcon(cw.weathercode, !!cw.is_day);
      const desc = weatherDesc(cw.weathercode);
      const colSep = `  ${dim("│")}  `;
      const colWidth = Math.max(18, Math.floor((innerW - 2 - visibleWidth(colSep) - 2) / 2));
      const metric = (label: string, value: string) => `${dim(label.padEnd(8))} ${value}`;
      const twoColLine = (left: string, right: string) =>
        boxLine(`  ${pad(left, colWidth)}${colSep}${pad(right, colWidth)}`);

      lines.push(boxLine(bold(yellow("  CURRENT CONDITIONS"))));
      lines.push(emptyLine());
      lines.push(twoColLine(
        metric("Temp", `${icon} ${bold(`${cw.temperature.toFixed(1)}°C`)}`),
        metric("Sky", desc),
      ));
      lines.push(twoColLine(
        metric("Wind", `${cw.windspeed} km/h ${windDirection(cw.winddirection)}`),
        metric("Updated", cw.time.split("T")[1].slice(0, 5)),
      ));

      // Sunrise/Sunset
      if (daily.sunrise[0] && daily.sunset[0]) {
        const rise = daily.sunrise[0].split("T")[1].slice(0, 5);
        const set = daily.sunset[0].split("T")[1].slice(0, 5);
        lines.push(twoColLine(
          metric("Sunrise", rise),
          metric("Sunset", set),
        ));
      }

      lines.push(truncateToWidth(border("├" + "─".repeat(innerW) + "┤"), width));

      // Hourly forecast (next 12 hours)
      lines.push(boxLine(bold(yellow("  NEXT 12 HOURS"))));
      lines.push(emptyLine());

      const now = new Date();
      const currentHourIdx = hourly.time.findIndex((t) => new Date(t) >= now);
      const startIdx = Math.max(0, currentHourIdx);

      for (let i = startIdx; i < Math.min(startIdx + 12, hourly.time.length); i += 2) {
        const time = hourly.time[i].split("T")[1].slice(0, 5);
        const temp = hourly.temperature_2m[i];
        const precip = hourly.precipitation_probability[i];
        const wcode = hourly.weathercode[i];
        const wind = hourly.windspeed_10m[i];
        const ic = weatherIcon(wcode);
        const bar = tempBar(temp, -5, 35, 10);
        const precipStr = precip > 0 ? cyan(`${precip}%`) : dim("0%");
        lines.push(boxLine(
          `  ${dim(time)} ${ic} ${bar} ${bold(temp.toFixed(1).padStart(5))}°C  💧${precipStr.padStart(4)}  💨${String(Math.round(wind)).padStart(3)}km/h`
        ));
      }

      lines.push(truncateToWidth(border("├" + "─".repeat(innerW) + "┤"), width));

      // 7-day forecast
      lines.push(boxLine(bold(yellow("  7-DAY FORECAST"))));
      lines.push(emptyLine());

      const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      for (let i = 0; i < Math.min(7, daily.time.length); i++) {
        const date = new Date(daily.time[i]);
        const dayName = i === 0 ? green(bold("Today ")) : (i === 1 ? "Tmrw  " : days[date.getDay()] + "   ");
        const ic = weatherIcon(daily.weathercode[i]);
        const hi = daily.temperature_2m_max[i];
        const lo = daily.temperature_2m_min[i];
        const rain = daily.precipitation_sum[i];
        const bar = tempBar((hi + lo) / 2, -5, 35, 8);
        const rainStr = rain > 0 ? cyan(`${rain.toFixed(1)}mm`) : dim("  0mm");
        lines.push(boxLine(
          `  ${dayName} ${ic} ${bar}  ${blue(lo.toFixed(0).padStart(3))}° / ${bold(yellow(hi.toFixed(0).padStart(3)))}°  🌧️ ${rainStr}`
        ));
      }
    }

    lines.push(truncateToWidth(border("├" + "─".repeat(innerW) + "┤"), width));
    lines.push(boxLine(dim("R refresh  •  Q/ESC close")));
    lines.push(truncateToWidth(border("╰" + "─".repeat(innerW) + "╯"), width));

    this.cachedLines = lines;
    this.cachedWidth = width;
    return lines;
  }
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("weather", {
    description: "Show weather dashboard for Horben, Aeschau, Switzerland",
    handler: async (_args, ctx) => {
      if (!ctx.hasUI) {
        ctx.ui.notify("Weather dashboard requires interactive mode", "error");
        return;
      }

      await ctx.ui.custom((tui, theme, _kb, done) => {
        return new WeatherDashboard(tui, theme, () => done(undefined));
      });
    },
  });
}
