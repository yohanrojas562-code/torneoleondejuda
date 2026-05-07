import { useState, useRef } from 'react';
import { PageProps } from '@/types';
import { Head, Link, useForm } from '@inertiajs/react';
import { motion } from 'framer-motion';
import {
    MessageSquare, ArrowLeft, Upload, X, FileText, Image as ImageIcon,
    Video, AlertTriangle, ThumbsUp, Megaphone, ScrollText, HelpCircle, Check,
} from 'lucide-react';
import MobileBottomNav from '@/Components/MobileBottomNav';
import MobileSideDrawer from '@/Components/MobileSideDrawer';

interface Team { id: number; name: string; }

type Props = PageProps<{
    teams: Team[];
    settings: Record<string, string | null>;
    typeOptions: Record<string, string>;
    roleOptions: Record<string, string>;
}>;

const fadeUp = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };

const typeIcons: Record<string, typeof HelpCircle> = {
    peticion: HelpCircle,
    queja: AlertTriangle,
    reclamo: ScrollText,
    sugerencia: Megaphone,
    apelacion: MessageSquare,
    felicitacion: ThumbsUp,
};

function fileIcon(file: File) {
    if (file.type.startsWith('image/')) return ImageIcon;
    if (file.type.startsWith('video/')) return Video;
    return FileText;
}

function humanSize(bytes: number) {
    if (bytes >= 1048576) return `${(bytes / 1048576).toFixed(2)} MB`;
    if (bytes >= 1024) return `${(bytes / 1024).toFixed(2)} KB`;
    return `${bytes} B`;
}

const MAX_FILES = 5;
const MAX_SIZE_MB = 25;

export default function PqrsCreate({ teams = [], settings = {}, typeOptions, roleOptions }: Props) {
    const fileInputRef = useRef<HTMLInputElement>(null);
    const [files, setFiles] = useState<File[]>([]);
    const [fileError, setFileError] = useState<string | null>(null);

    const { data, setData, post, processing, errors, reset } = useForm({
        type: '',
        subject: '',
        description: '',
        submitter_name: '',
        submitter_email: '',
        submitter_phone: '',
        submitter_team_id: '',
        submitter_role: '',
        attachments: [] as File[],
        privacy_accepted: false as boolean,
        website: '', // honeypot
    });

    const siteName = settings.site_name || 'Torneo León de Judá';
    const logoUrl = settings.logo ? `/storage/${settings.logo}` : null;

    const handleFiles = (incoming: FileList | null) => {
        if (!incoming) return;
        const next: File[] = [...files];
        let err: string | null = null;

        Array.from(incoming).forEach((f) => {
            if (next.length >= MAX_FILES) { err = `Máximo ${MAX_FILES} archivos.`; return; }
            if (f.size > MAX_SIZE_MB * 1024 * 1024) { err = `"${f.name}" supera ${MAX_SIZE_MB} MB.`; return; }
            const validMime =
                f.type.startsWith('image/') ||
                f.type.startsWith('video/') ||
                f.type === 'application/pdf';
            if (!validMime) { err = `"${f.name}" no es un formato permitido.`; return; }
            next.push(f);
        });

        setFiles(next);
        setData('attachments', next);
        setFileError(err);
        if (fileInputRef.current) fileInputRef.current.value = '';
    };

    const removeFile = (idx: number) => {
        const next = files.filter((_, i) => i !== idx);
        setFiles(next);
        setData('attachments', next);
        setFileError(null);
    };

    const submit = (e: React.FormEvent) => {
        e.preventDefault();
        post('/pqrs', {
            forceFormData: true,
            onSuccess: () => reset(),
        });
    };

    return (
        <>
            <Head>
                <title>{`PQRS - ${siteName}`}</title>
                <meta name="description" content="Presenta peticiones, quejas, reclamos, sugerencias o apelaciones del torneo." />
            </Head>

            <div className="bg-brand-black min-h-screen flex flex-col">
                <header className="bg-brand-black/95 backdrop-blur-sm border-b border-brand-gold/20">
                    <div className="max-w-3xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between">
                        <Link href="/" className="flex items-center gap-3">
                            {logoUrl
                                ? <img src={logoUrl} alt={siteName} className="h-10 w-10 object-contain" />
                                : <span className="text-brand-gold font-bold text-xl">LJ</span>
                            }
                            <span className="text-white font-bold text-base hidden sm:block">{siteName}</span>
                        </Link>
                        <Link href="/" className="hidden sm:flex text-gray-300 hover:text-brand-gold transition items-center gap-1.5 text-sm">
                            <ArrowLeft className="w-4 h-4" />
                            <span>Volver al inicio</span>
                        </Link>
                        <MobileSideDrawer />
                    </div>
                </header>

                <main className="flex-1 py-10 px-4">
                    <div className="max-w-2xl mx-auto">
                        <motion.div initial="hidden" animate="visible" variants={fadeUp} className="text-center mb-8">
                            <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-brand-gold/10 mb-4">
                                <MessageSquare className="w-7 h-7 text-brand-gold" />
                            </div>
                            <h1 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">PQRS</h1>
                            <p className="text-gray-400 mt-2 text-sm">
                                Peticiones, quejas, reclamos, sugerencias y apelaciones
                            </p>
                        </motion.div>

                        <form onSubmit={submit} className="space-y-6" noValidate>
                            {/* honeypot */}
                            <input
                                type="text"
                                name="website"
                                tabIndex={-1}
                                autoComplete="off"
                                value={data.website}
                                onChange={(e) => setData('website', e.target.value)}
                                className="hidden"
                                aria-hidden="true"
                            />

                            {/* Tipo */}
                            <div>
                                <label className="block text-white font-semibold text-sm mb-3">Tipo de solicitud *</label>
                                <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                                    {Object.entries(typeOptions).map(([value, label]) => {
                                        const Icon = typeIcons[value] || HelpCircle;
                                        const active = data.type === value;
                                        return (
                                            <button
                                                key={value}
                                                type="button"
                                                onClick={() => setData('type', value)}
                                                className={`flex flex-col items-center justify-center gap-1.5 p-3 rounded-xl border transition-all ${
                                                    active
                                                        ? 'bg-brand-gold/10 border-brand-gold text-brand-gold'
                                                        : 'bg-white/[0.03] border-white/10 text-gray-400 hover:border-white/20 hover:text-gray-200'
                                                }`}
                                            >
                                                <Icon className="w-5 h-5" />
                                                <span className="text-xs font-semibold">{label}</span>
                                            </button>
                                        );
                                    })}
                                </div>
                                {errors.type && <p className="text-red-400 text-xs mt-2">{errors.type}</p>}
                            </div>

                            {/* Asunto */}
                            <div>
                                <label className="block text-white font-semibold text-sm mb-2">Asunto *</label>
                                <input
                                    type="text"
                                    value={data.subject}
                                    onChange={(e) => setData('subject', e.target.value)}
                                    maxLength={200}
                                    className="w-full bg-white/[0.03] border border-white/10 rounded-lg px-4 py-2.5 text-white placeholder-gray-600 text-sm focus:outline-none focus:border-brand-gold transition"
                                    placeholder="Resumen breve de tu solicitud"
                                />
                                {errors.subject && <p className="text-red-400 text-xs mt-1">{errors.subject}</p>}
                            </div>

                            {/* Descripción */}
                            <div>
                                <label className="block text-white font-semibold text-sm mb-2">Descripción *</label>
                                <textarea
                                    rows={6}
                                    value={data.description}
                                    onChange={(e) => setData('description', e.target.value)}
                                    maxLength={5000}
                                    className="w-full bg-white/[0.03] border border-white/10 rounded-lg px-4 py-2.5 text-white placeholder-gray-600 text-sm focus:outline-none focus:border-brand-gold transition resize-y"
                                    placeholder="Describe tu caso con el mayor detalle posible: qué pasó, cuándo, dónde y quiénes estuvieron involucrados."
                                />
                                <div className="flex justify-between mt-1">
                                    {errors.description ? <p className="text-red-400 text-xs">{errors.description}</p> : <span />}
                                    <span className="text-gray-600 text-xs">{data.description.length}/5000</span>
                                </div>
                            </div>

                            {/* Datos del solicitante */}
                            <div className="bg-white/[0.02] border border-white/10 rounded-xl p-5">
                                <p className="text-brand-gold text-xs font-semibold uppercase tracking-wider mb-4">Tus datos</p>

                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                    <div className="sm:col-span-2">
                                        <label className="block text-white font-semibold text-sm mb-2">Nombre completo *</label>
                                        <input
                                            type="text"
                                            value={data.submitter_name}
                                            onChange={(e) => setData('submitter_name', e.target.value)}
                                            maxLength={150}
                                            className="w-full bg-white/[0.03] border border-white/10 rounded-lg px-4 py-2.5 text-white placeholder-gray-600 text-sm focus:outline-none focus:border-brand-gold transition"
                                            placeholder="Tu nombre completo"
                                        />
                                        {errors.submitter_name && <p className="text-red-400 text-xs mt-1">{errors.submitter_name}</p>}
                                    </div>

                                    <div>
                                        <label className="block text-white font-semibold text-sm mb-2">Correo electrónico *</label>
                                        <input
                                            type="email"
                                            value={data.submitter_email}
                                            onChange={(e) => setData('submitter_email', e.target.value)}
                                            className="w-full bg-white/[0.03] border border-white/10 rounded-lg px-4 py-2.5 text-white placeholder-gray-600 text-sm focus:outline-none focus:border-brand-gold transition"
                                            placeholder="tu@email.com"
                                        />
                                        {errors.submitter_email && <p className="text-red-400 text-xs mt-1">{errors.submitter_email}</p>}
                                    </div>

                                    <div>
                                        <label className="block text-white font-semibold text-sm mb-2">Teléfono <span className="text-gray-600 font-normal">(opcional)</span></label>
                                        <input
                                            type="tel"
                                            value={data.submitter_phone}
                                            onChange={(e) => setData('submitter_phone', e.target.value)}
                                            className="w-full bg-white/[0.03] border border-white/10 rounded-lg px-4 py-2.5 text-white placeholder-gray-600 text-sm focus:outline-none focus:border-brand-gold transition"
                                            placeholder="+57 300 0000000"
                                        />
                                        {errors.submitter_phone && <p className="text-red-400 text-xs mt-1">{errors.submitter_phone}</p>}
                                    </div>

                                    <div>
                                        <label className="block text-white font-semibold text-sm mb-2">Tu rol *</label>
                                        <select
                                            value={data.submitter_role}
                                            onChange={(e) => setData('submitter_role', e.target.value)}
                                            className="w-full bg-white/[0.03] border border-white/10 rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-brand-gold transition"
                                        >
                                            <option value="" className="bg-brand-black">Selecciona tu rol</option>
                                            {Object.entries(roleOptions).map(([value, label]) => (
                                                <option key={value} value={value} className="bg-brand-black">{label}</option>
                                            ))}
                                        </select>
                                        {errors.submitter_role && <p className="text-red-400 text-xs mt-1">{errors.submitter_role}</p>}
                                    </div>

                                    <div>
                                        <label className="block text-white font-semibold text-sm mb-2">Equipo <span className="text-gray-600 font-normal">(si aplica)</span></label>
                                        <select
                                            value={data.submitter_team_id}
                                            onChange={(e) => setData('submitter_team_id', e.target.value)}
                                            className="w-full bg-white/[0.03] border border-white/10 rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-brand-gold transition"
                                        >
                                            <option value="" className="bg-brand-black">No aplica</option>
                                            {teams.map((t) => (
                                                <option key={t.id} value={t.id} className="bg-brand-black">{t.name}</option>
                                            ))}
                                        </select>
                                        {errors.submitter_team_id && <p className="text-red-400 text-xs mt-1">{errors.submitter_team_id}</p>}
                                    </div>
                                </div>
                            </div>

                            {/* Evidencias */}
                            <div>
                                <label className="block text-white font-semibold text-sm mb-2">
                                    Evidencias <span className="text-gray-600 font-normal">(opcional, máx. 5 archivos · 25 MB c/u)</span>
                                </label>
                                <div className="bg-white/[0.03] border-2 border-dashed border-white/10 hover:border-brand-gold/40 rounded-xl p-5 transition">
                                    <input
                                        ref={fileInputRef}
                                        type="file"
                                        multiple
                                        accept="image/*,video/*,application/pdf"
                                        onChange={(e) => handleFiles(e.target.files)}
                                        className="hidden"
                                        id="file-input"
                                    />
                                    <label
                                        htmlFor="file-input"
                                        className="flex flex-col items-center justify-center gap-2 cursor-pointer text-center py-3"
                                    >
                                        <div className="w-10 h-10 rounded-full bg-brand-gold/10 flex items-center justify-center">
                                            <Upload className="w-5 h-5 text-brand-gold" />
                                        </div>
                                        <span className="text-white text-sm font-semibold">Toca para seleccionar archivos</span>
                                        <span className="text-gray-500 text-xs">Imágenes, videos o PDF</span>
                                    </label>

                                    {files.length > 0 && (
                                        <div className="mt-4 pt-4 border-t border-white/10 space-y-2">
                                            {files.map((f, idx) => {
                                                const Icon = fileIcon(f);
                                                return (
                                                    <div key={idx} className="flex items-center gap-3 bg-white/[0.03] rounded-lg p-2.5">
                                                        <Icon className="w-4 h-4 text-brand-gold flex-shrink-0" />
                                                        <div className="flex-1 min-w-0">
                                                            <p className="text-white text-xs font-medium truncate">{f.name}</p>
                                                            <p className="text-gray-600 text-[10px]">{humanSize(f.size)}</p>
                                                        </div>
                                                        <button
                                                            type="button"
                                                            onClick={() => removeFile(idx)}
                                                            className="text-gray-500 hover:text-red-400 transition flex-shrink-0"
                                                            aria-label={`Eliminar ${f.name}`}
                                                        >
                                                            <X className="w-4 h-4" />
                                                        </button>
                                                    </div>
                                                );
                                            })}
                                        </div>
                                    )}
                                </div>
                                {fileError && <p className="text-red-400 text-xs mt-2">{fileError}</p>}
                                {errors.attachments && <p className="text-red-400 text-xs mt-2">{errors.attachments}</p>}
                                {Object.keys(errors).filter(k => k.startsWith('attachments.')).map(k => (
                                    <p key={k} className="text-red-400 text-xs mt-1">{(errors as any)[k]}</p>
                                ))}
                            </div>

                            {/* Privacidad */}
                            <label className="flex items-start gap-3 cursor-pointer">
                                <input
                                    type="checkbox"
                                    checked={data.privacy_accepted}
                                    onChange={(e) => setData('privacy_accepted', e.target.checked)}
                                    className="mt-1 w-4 h-4 rounded border-white/20 bg-white/[0.03] text-brand-gold focus:ring-brand-gold focus:ring-offset-0 focus:ring-offset-transparent"
                                />
                                <span className="text-gray-400 text-xs leading-relaxed">
                                    Acepto el tratamiento de mis datos personales para la gestión de esta solicitud según las políticas del torneo. *
                                </span>
                            </label>
                            {errors.privacy_accepted && <p className="text-red-400 text-xs">{errors.privacy_accepted}</p>}

                            {/* Submit */}
                            <button
                                type="submit"
                                disabled={processing}
                                className="w-full bg-brand-gold hover:bg-brand-gold-light disabled:opacity-60 disabled:cursor-not-allowed text-black font-bold py-3 rounded-lg transition flex items-center justify-center gap-2"
                            >
                                {processing ? (
                                    <>
                                        <span className="w-4 h-4 border-2 border-black border-t-transparent rounded-full animate-spin" />
                                        Enviando...
                                    </>
                                ) : (
                                    <>
                                        <Check className="w-5 h-5" />
                                        Enviar solicitud
                                    </>
                                )}
                            </button>
                        </form>
                    </div>
                </main>

                <footer className="bg-brand-black border-t border-white/10 py-6 px-4">
                    <div className="max-w-5xl mx-auto text-center">
                        <p className="text-gray-600 text-xs">© {new Date().getFullYear()} {siteName}. Todos los derechos reservados.</p>
                    </div>
                </footer>

                <MobileBottomNav />
            </div>
        </>
    );
}
