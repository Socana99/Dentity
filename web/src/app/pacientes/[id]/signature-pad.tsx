"use client";

import { useEffect, useRef, useState } from "react";

export default function SignaturePad({
  label,
  initialValue,
  onChange,
}: {
  label: string;
  initialValue?: string | null;
  onChange: (dataUrl: string) => void;
}) {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const drawingRef = useRef(false);
  const [hasStroke, setHasStroke] = useState(!!initialValue);

  useEffect(() => {
    const canvas = canvasRef.current;
    const c = canvas?.getContext("2d");
    if (!canvas || !c || !initialValue) return;
    const img = new Image();
    img.onload = () => c.drawImage(img, 0, 0, canvas.width, canvas.height);
    img.src = initialValue;
    // Solo se carga la firma inicial una vez al montar.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function ctx() {
    return canvasRef.current?.getContext("2d") ?? null;
  }

  function pointFromEvent(e: React.PointerEvent<HTMLCanvasElement>) {
    const canvas = canvasRef.current!;
    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;
    return {
      x: (e.clientX - rect.left) * scaleX,
      y: (e.clientY - rect.top) * scaleY,
    };
  }

  function start(e: React.PointerEvent<HTMLCanvasElement>) {
    const c = ctx();
    if (!c) return;
    canvasRef.current?.setPointerCapture(e.pointerId);
    drawingRef.current = true;
    const { x, y } = pointFromEvent(e);
    c.beginPath();
    c.moveTo(x, y);
  }

  function move(e: React.PointerEvent<HTMLCanvasElement>) {
    if (!drawingRef.current) return;
    const c = ctx();
    if (!c) return;
    const { x, y } = pointFromEvent(e);
    c.lineWidth = 2.5;
    c.lineCap = "round";
    c.strokeStyle = "#444444";
    c.lineTo(x, y);
    c.stroke();
  }

  function end() {
    if (!drawingRef.current) return;
    drawingRef.current = false;
    setHasStroke(true);
    const canvas = canvasRef.current;
    if (canvas) onChange(canvas.toDataURL("image/png"));
  }

  function clear() {
    const canvas = canvasRef.current;
    const c = ctx();
    if (!canvas || !c) return;
    c.clearRect(0, 0, canvas.width, canvas.height);
    setHasStroke(false);
    onChange("");
  }

  return (
    <div>
      <div className="mb-1.5 flex items-center justify-between">
        <span className="text-xs font-medium text-gray-500">{label}</span>
        {hasStroke && (
          <button
            type="button"
            onClick={clear}
            className="animate-fade-in-up text-xs font-medium text-red-500 transition-transform duration-150 ease-[var(--ease-out)] hover:underline active:scale-95"
          >
            Limpiar
          </button>
        )}
      </div>
      <canvas
        ref={canvasRef}
        width={600}
        height={180}
        onPointerDown={start}
        onPointerMove={move}
        onPointerUp={end}
        onPointerLeave={end}
        className="h-[120px] w-full touch-none rounded-2xl border-2 border-dashed border-primary/40 bg-gray-50"
      />
    </div>
  );
}
