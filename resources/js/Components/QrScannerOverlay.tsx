import { useEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import { motion } from 'framer-motion';
import { X, Camera, AlertTriangle, ScanLine } from 'lucide-react';

type Status = 'starting' | 'scanning' | 'unsupported' | 'denied' | 'error';

export default function QrScannerOverlay({
    onClose,
    onResult,
}: {
    onClose: () => void;
    onResult: (text: string) => void;
}) {
    const videoRef = useRef<HTMLVideoElement>(null);
    const streamRef = useRef<MediaStream | null>(null);
    const intervalRef = useRef<number | null>(null);
    const [status, setStatus] = useState<Status>('starting');
    const [errorMsg, setErrorMsg] = useState<string>('');
    const [mounted, setMounted] = useState(false);

    useEffect(() => {
        setMounted(true);
    }, []);

    useEffect(() => {
        const original = document.body.style.overflow;
        document.body.style.overflow = 'hidden';
        return () => {
            document.body.style.overflow = original;
        };
    }, []);

    useEffect(() => {
        const handler = (e: KeyboardEvent) => {
            if (e.key === 'Escape') onClose();
        };
        window.addEventListener('keydown', handler);
        return () => window.removeEventListener('keydown', handler);
    }, [onClose]);

    const stopStream = () => {
        if (intervalRef.current) {
            window.clearInterval(intervalRef.current);
            intervalRef.current = null;
        }
        if (streamRef.current) {
            streamRef.current.getTracks().forEach((t) => t.stop());
            streamRef.current = null;
        }
    };

    useEffect(() => {
        const Detector = (window as any).BarcodeDetector;

        if (!Detector) {
            setStatus('unsupported');
            return;
        }
        if (!navigator.mediaDevices?.getUserMedia) {
            setStatus('unsupported');
            return;
        }

        let cancelled = false;

        (async () => {
            try {
                const formats = (await Detector.getSupportedFormats?.()) ?? ['qr_code'];
                if (!formats.includes('qr_code')) {
                    if (!cancelled) setStatus('unsupported');
                    return;
                }

                const detector = new Detector({ formats: ['qr_code'] });

                const stream = await navigator.mediaDevices.getUserMedia({
                    video: { facingMode: { ideal: 'environment' } },
                    audio: false,
                });

                if (cancelled) {
                    stream.getTracks().forEach((t) => t.stop());
                    return;
                }

                streamRef.current = stream;
                if (videoRef.current) {
                    videoRef.current.srcObject = stream;
                    await videoRef.current.play().catch(() => {});
                }

                setStatus('scanning');

                intervalRef.current = window.setInterval(async () => {
                    if (!videoRef.current || cancelled) return;
                    try {
                        const codes = await detector.detect(videoRef.current);
                        if (codes && codes.length > 0) {
                            const value = codes[0].rawValue ?? '';
                            if (value) {
                                stopStream();
                                onResult(value);
                            }
                        }
                    } catch {
                        // ignore individual frame failures
                    }
                }, 400);
            } catch (e: any) {
                if (cancelled) return;
                if (e?.name === 'NotAllowedError' || e?.name === 'PermissionDeniedError') {
                    setStatus('denied');
                } else {
                    setErrorMsg(e?.message || 'No se pudo iniciar la cámara');
                    setStatus('error');
                }
            }
        })();

        return () => {
            cancelled = true;
            stopStream();
        };
    }, [onResult]);

    if (!mounted) return null;

    return createPortal(
        <div className="fixed inset-0 z-[90] flex items-center justify-center p-4">
            <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.2 }}
                onClick={onClose}
                className="absolute inset-0 bg-black/90 backdrop-blur-md"
            />
            <motion.div
                initial={{ opacity: 0, scale: 0.95, y: 16 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.95, y: 8 }}
                transition={{ duration: 0.25, ease: 'easeOut' }}
                role="dialog"
                aria-modal="true"
                aria-label="Escanear QR del carnet"
                className="relative bg-brand-black border border-brand-gold/30 rounded-3xl max-w-md w-full overflow-hidden shadow-[0_0_80px_rgba(214,143,3,0.2)]"
            >
                <button
                    type="button"
                    onClick={onClose}
                    aria-label="Cerrar"
                    className="absolute top-3 right-3 z-10 inline-flex items-center justify-center w-10 h-10 rounded-full bg-black/60 backdrop-blur text-gray-200 hover:bg-black/80 hover:text-brand-gold transition"
                >
                    <X className="w-5 h-5" />
                </button>

                <div className="p-5 pb-3 flex items-center justify-center gap-2 border-b border-white/5">
                    <ScanLine className="w-5 h-5 text-brand-gold" />
                    <h3 className="text-white font-bold text-base">Escanear QR del carnet</h3>
                </div>

                <div className="relative aspect-square bg-black overflow-hidden">
                    {status === 'starting' && (
                        <div className="absolute inset-0 flex flex-col items-center justify-center text-gray-400 text-sm gap-3">
                            <span className="w-8 h-8 border-2 border-brand-gold border-t-transparent rounded-full animate-spin" />
                            <p>Iniciando cámara…</p>
                        </div>
                    )}

                    {status === 'scanning' && (
                        <>
                            <video
                                ref={videoRef}
                                playsInline
                                muted
                                autoPlay
                                className="w-full h-full object-cover"
                            />
                            {/* Marco guia para alinear el QR */}
                            <div className="pointer-events-none absolute inset-10 border-2 border-brand-gold/70 rounded-2xl">
                                <span className="absolute -top-px -left-px w-6 h-6 border-t-4 border-l-4 border-brand-gold rounded-tl-2xl" />
                                <span className="absolute -top-px -right-px w-6 h-6 border-t-4 border-r-4 border-brand-gold rounded-tr-2xl" />
                                <span className="absolute -bottom-px -left-px w-6 h-6 border-b-4 border-l-4 border-brand-gold rounded-bl-2xl" />
                                <span className="absolute -bottom-px -right-px w-6 h-6 border-b-4 border-r-4 border-brand-gold rounded-br-2xl" />
                            </div>
                        </>
                    )}

                    {status === 'unsupported' && (
                        <div className="absolute inset-0 flex flex-col items-center justify-center text-center text-gray-300 px-6 gap-3">
                            <AlertTriangle className="w-10 h-10 text-yellow-400" />
                            <p className="font-semibold text-sm">Escaneo en vivo no disponible</p>
                            <p className="text-xs text-gray-500 leading-relaxed">
                                Tu navegador no soporta escaneo en vivo. Usa la cámara de tu celular y apunta al QR del carnet —
                                te abrirá esta página automáticamente con la ficha del jugador.
                            </p>
                        </div>
                    )}

                    {status === 'denied' && (
                        <div className="absolute inset-0 flex flex-col items-center justify-center text-center text-gray-300 px-6 gap-3">
                            <Camera className="w-10 h-10 text-red-400" />
                            <p className="font-semibold text-sm">Acceso a la cámara denegado</p>
                            <p className="text-xs text-gray-500 leading-relaxed">
                                Activa el permiso de cámara para este sitio en la configuración de tu navegador e intenta de nuevo.
                            </p>
                        </div>
                    )}

                    {status === 'error' && (
                        <div className="absolute inset-0 flex flex-col items-center justify-center text-center text-gray-300 px-6 gap-3">
                            <AlertTriangle className="w-10 h-10 text-red-400" />
                            <p className="font-semibold text-sm">No se pudo iniciar la cámara</p>
                            {errorMsg && <p className="text-xs text-gray-500">{errorMsg}</p>}
                        </div>
                    )}
                </div>

                <div className="p-4 text-center">
                    <p className="text-gray-500 text-xs">
                        {status === 'scanning'
                            ? 'Apunta la cámara al código QR del carnet'
                            : status === 'starting'
                            ? 'Permite el acceso a la cámara cuando el navegador lo pida'
                            : ''}
                    </p>
                </div>
            </motion.div>
        </div>,
        document.body
    );
}
