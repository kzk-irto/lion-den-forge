-- Criar tabela de perfis dos usuários
CREATE TABLE public.profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  bio TEXT,
  avatar_url TEXT,
  course TEXT, -- Tech Skills, Letramento em IA, Liderança em Tecnologia
  github_url TEXT,
  linkedin_url TEXT,
  total_points INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Criar tabela de projetos
CREATE TABLE public.projects (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  demo_url TEXT,
  github_url TEXT,
  image_url TEXT,
  video_url TEXT,
  technologies TEXT[], -- Array de tecnologias usadas
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'archived')),
  votes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Criar tabela de badges
CREATE TABLE public.badges (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon_name TEXT, -- Nome do ícone a ser usado
  color TEXT, -- Cor do badge
  points INTEGER DEFAULT 0, -- Pontos que o badge vale
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Criar tabela de badges dos usuários
CREATE TABLE public.user_badges (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  badge_id UUID NOT NULL REFERENCES public.badges(id) ON DELETE CASCADE,
  earned_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id, badge_id)
);

-- Criar tabela de votos nos projetos
CREATE TABLE public.project_votes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(project_id, user_id)
);

-- Criar tabela de comentários
CREATE TABLE public.comments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  parent_id UUID REFERENCES public.comments(id) ON DELETE CASCADE, -- Para replies
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Criar tabela de tags
CREATE TABLE public.tags (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  color TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Criar tabela de relação projeto-tags
CREATE TABLE public.project_tags (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
  UNIQUE(project_id, tag_id)
);

-- Habilitar RLS em todas as tabelas
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_tags ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para profiles
CREATE POLICY "Perfis são visíveis para todos" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Usuários podem atualizar seu próprio perfil" ON public.profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Usuários podem inserir seu próprio perfil" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas RLS para projects
CREATE POLICY "Projetos são visíveis para todos" ON public.projects FOR SELECT USING (true);
CREATE POLICY "Usuários podem criar seus próprios projetos" ON public.projects FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuários podem atualizar seus próprios projetos" ON public.projects FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Usuários podem deletar seus próprios projetos" ON public.projects FOR DELETE USING (auth.uid() = user_id);

-- Políticas RLS para badges
CREATE POLICY "Badges são visíveis para todos" ON public.badges FOR SELECT USING (true);

-- Políticas RLS para user_badges
CREATE POLICY "Badges dos usuários são visíveis para todos" ON public.user_badges FOR SELECT USING (true);

-- Políticas RLS para project_votes
CREATE POLICY "Votos são visíveis para todos" ON public.project_votes FOR SELECT USING (true);
CREATE POLICY "Usuários podem votar em projetos" ON public.project_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuários podem remover seus próprios votos" ON public.project_votes FOR DELETE USING (auth.uid() = user_id);

-- Políticas RLS para comments
CREATE POLICY "Comentários são visíveis para todos" ON public.comments FOR SELECT USING (true);
CREATE POLICY "Usuários podem criar comentários" ON public.comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuários podem atualizar seus próprios comentários" ON public.comments FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Usuários podem deletar seus próprios comentários" ON public.comments FOR DELETE USING (auth.uid() = user_id);

-- Políticas RLS para tags
CREATE POLICY "Tags são visíveis para todos" ON public.tags FOR SELECT USING (true);

-- Políticas RLS para project_tags
CREATE POLICY "Tags de projetos são visíveis para todos" ON public.project_tags FOR SELECT USING (true);

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para atualizar updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON public.comments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger para criar perfil automaticamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (user_id, display_name)
  VALUES (NEW.id, NEW.raw_user_meta_data ->> 'display_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Função para atualizar contador de votos
CREATE OR REPLACE FUNCTION public.update_project_votes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.projects 
    SET votes_count = votes_count + 1 
    WHERE id = NEW.project_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.projects 
    SET votes_count = votes_count - 1 
    WHERE id = OLD.project_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER update_votes_count
  AFTER INSERT OR DELETE ON public.project_votes
  FOR EACH ROW EXECUTE FUNCTION public.update_project_votes_count();

-- Função para atualizar contador de comentários
CREATE OR REPLACE FUNCTION public.update_project_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.projects 
    SET comments_count = comments_count + 1 
    WHERE id = NEW.project_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.projects 
    SET comments_count = comments_count - 1 
    WHERE id = OLD.project_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER update_comments_count
  AFTER INSERT OR DELETE ON public.comments
  FOR EACH ROW EXECUTE FUNCTION public.update_project_comments_count();

-- Inserir badges iniciais
INSERT INTO public.badges (name, description, icon_name, color, points) VALUES
('Primeiro Projeto', 'Publicou seu primeiro projeto na Lion''s Den', 'trophy', '#FFD700', 10),
('Leão Colaborativo', 'Recebeu 10 comentários em seus projetos', 'users', '#FF6B35', 25),
('Rugido da Comunidade', 'Projeto alcançou 50 votos', 'heart', '#E74C3C', 50),
('Mestre dos Códigos', 'Publicou 5 projetos usando diferentes tecnologias', 'code', '#3498DB', 75),
('Mentor Leão', 'Fez 25 comentários úteis em projetos', 'message-circle', '#2ECC71', 30);

-- Inserir tags iniciais
INSERT INTO public.tags (name, color) VALUES
('React', '#61DAFB'),
('JavaScript', '#F7DF1E'),
('Python', '#3776AB'),
('Node.js', '#339933'),
('TypeScript', '#3178C6'),
('IA/ML', '#FF6F00'),
('GPT', '#10A37F'),
('Next.js', '#000000'),
('Supabase', '#3ECF8E'),
('Firebase', '#FFCA28');