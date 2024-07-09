/**
 * Funcion para redondear numeros
 * @param value Numero a redondear
 * @param precision Numero de decimales
 * @returns Numero redondeado.
 */
export function round(value: number, precision: number): number {
  const factor = Math.pow(10, precision);
  return Math.round(value * factor) / factor;
}

export function devaluation(tasaA: number, tasaB: number, dias: number): number {
  if( dias === 0 ) return 0;
  return Math.pow(tasaA / tasaB, 365 / dias) - 1;
}
