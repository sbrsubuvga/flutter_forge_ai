import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'FlutterForge Cloud',
  description: 'AI Debug Snapshots from your Flutter apps.',
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>
        <header
          style={{
            padding: '16px 24px',
            borderBottom: '1px solid #eee',
            fontFamily: 'system-ui, sans-serif',
          }}
        >
          <strong>🛠️ FlutterForge Cloud</strong>{' '}
          <span style={{ color: '#888', fontSize: 13 }}>v0.1 scaffold</span>
        </header>
        <main style={{ padding: 24, fontFamily: 'system-ui, sans-serif' }}>
          {children}
        </main>
      </body>
    </html>
  );
}
