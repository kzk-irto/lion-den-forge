import { useAuth } from '@/contexts/AuthContext';
import { Button } from '@/components/ui/button';
import { Crown, Users, Trophy, Zap, User, LogOut } from 'lucide-react';
import { ProtectedRoute } from '@/components/ProtectedRoute';

const Index = () => {
  const { user, signOut } = useAuth();

  return (
    <ProtectedRoute>
      <div className="min-h-screen bg-gradient-to-br from-background via-background to-primary/5">
        {/* Header */}
        <header className="border-b border-primary/20 bg-background/80 backdrop-blur-sm">
          <div className="container mx-auto px-4 py-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <Crown className="h-8 w-8 text-primary" />
                <h1 className="text-2xl font-bold bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
                  Lion's Den
                </h1>
              </div>
              
              <div className="flex items-center gap-4">
                <div className="flex items-center gap-2 text-sm">
                  <User className="h-4 w-4" />
                  <span className="font-medium">{user?.email}</span>
                </div>
                <Button 
                  variant="outline" 
                  size="sm"
                  onClick={signOut}
                  className="flex items-center gap-2"
                >
                  <LogOut className="h-4 w-4" />
                  Sair
                </Button>
              </div>
            </div>
          </div>
        </header>

        {/* Hero Section */}
        <main className="container mx-auto px-4 py-12">
          <div className="text-center mb-12">
            <div className="flex justify-center mb-6">
              <div className="relative">
                <div className="h-24 w-24 bg-gradient-to-br from-primary to-accent rounded-full flex items-center justify-center">
                  <Crown className="h-12 w-12 text-white" />
                </div>
                <div className="absolute -top-2 -right-2">
                  <Zap className="h-8 w-8 text-accent" />
                </div>
              </div>
            </div>
            
            <h2 className="text-4xl md:text-6xl font-bold mb-4 bg-gradient-to-r from-primary via-accent to-primary bg-clip-text text-transparent">
              Bem-vindo à Arena
            </h2>
            
            <p className="text-xl text-muted-foreground max-w-2xl mx-auto mb-8">
              O coração pulsante da comunidade de inovadores da Lions Startups. 
              Aqui você exibe projetos, compete, colabora e constrói seu portfólio validado.
            </p>

            <div className="flex flex-wrap justify-center gap-4">
              <Button size="lg" className="flex items-center gap-2">
                <Trophy className="h-5 w-5" />
                Publicar Projeto
              </Button>
              <Button variant="outline" size="lg" className="flex items-center gap-2">
                <Users className="h-5 w-5" />
                Explorar Arena
              </Button>
            </div>
          </div>

          {/* Stats Cards */}
          <div className="grid md:grid-cols-3 gap-6 max-w-4xl mx-auto">
            <div className="bg-card border border-primary/20 rounded-lg p-6 text-center">
              <Trophy className="h-12 w-12 text-primary mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-primary">0</h3>
              <p className="text-muted-foreground">Projetos Publicados</p>
            </div>
            
            <div className="bg-card border border-accent/20 rounded-lg p-6 text-center">
              <Users className="h-12 w-12 text-accent mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-accent">0</h3>
              <p className="text-muted-foreground">Pontos Conquistados</p>
            </div>
            
            <div className="bg-card border border-secondary/20 rounded-lg p-6 text-center">
              <Crown className="h-12 w-12 text-secondary mx-auto mb-4" />
              <h3 className="text-2xl font-bold text-secondary">Novato</h3>
              <p className="text-muted-foreground">Posição no Ranking</p>
            </div>
          </div>

          {/* Coming Soon */}
          <div className="mt-16 text-center">
            <div className="bg-gradient-to-r from-primary/10 to-accent/10 rounded-lg p-8 max-w-2xl mx-auto">
              <h3 className="text-2xl font-bold mb-4">🚧 Em Construção</h3>
              <p className="text-muted-foreground">
                A arena está sendo preparada. Em breve você poderá:
              </p>
              <ul className="mt-4 space-y-2 text-left">
                <li className="flex items-center gap-2">
                  <Crown className="h-4 w-4 text-primary" />
                  <span>Publicar seus projetos com galeria e demos</span>
                </li>
                <li className="flex items-center gap-2">
                  <Trophy className="h-4 w-4 text-accent" />
                  <span>Competir no ranking e conquistar badges</span>
                </li>
                <li className="flex items-center gap-2">
                  <Users className="h-4 w-4 text-secondary" />
                  <span>Colaborar e formar equipes</span>
                </li>
              </ul>
            </div>
          </div>
        </main>
      </div>
    </ProtectedRoute>
  );
};

export default Index;
