-- ============================================================
-- Seed 001: Catálogo de exercícios do sistema
-- ============================================================
-- Insere ~60 exercícios reais cobrindo todos os grupos musculares.
-- Usa ON CONFLICT para ser idempotente (pode rodar várias vezes).
-- ============================================================

INSERT INTO exercises (name, muscle_group, description, instructions, is_custom) VALUES

-- ─── PEITO ────────────────────────────────────────────────
('Supino Reto com Barra',       'chest',     'Exercício clássico para desenvolvimento do peitoral maior.',
 '1. Deite no banco. 2. Segure a barra na largura dos ombros. 3. Desça até o peito. 4. Empurre até estender os cotovelos.',
 FALSE),

('Supino Inclinado com Halteres','chest',    'Foca na porção superior do peitoral.',
 '1. Incline o banco 30-45°. 2. Segure os halteres na altura do peito. 3. Pressione para cima. 4. Retorne com controle.',
 FALSE),

('Supino Declinado com Barra',  'chest',     'Ativa a porção inferior do peitoral.',
 '1. Decline o banco. 2. Pegue a barra com grip largo. 3. Desça ao peito. 4. Empurre explosivamente.',
 FALSE),

('Crucifixo com Halteres',      'chest',     'Isola o peitoral, focando no alongamento.',
 '1. Deite no banco plano. 2. Abra os braços em arco. 3. Sinta o alongamento no peito. 4. Feche trazendo os halteres.',
 FALSE),

('Peck Deck (Voador)',           'chest',     'Máquina para isolamento do peitoral.',
 '1. Ajuste o banco. 2. Coloque os braços nas alavancas. 3. Feche os braços à frente. 4. Retorne com controle.',
 FALSE),

('Flexão de Braço',             'chest',     'Exercício calistênico para peitoral e tríceps.',
 '1. Mãos na largura dos ombros. 2. Corpo reto. 3. Desça até o peito quase tocar o chão. 4. Empurre de volta.',
 FALSE),

-- ─── COSTAS ────────────────────────────────────────────────
('Puxada Frontal na Barra',     'back',      'Exercício fundamental para largura das costas.',
 '1. Segure a barra acima da cabeça. 2. Puxe até a barra tocar a parte superior do peito. 3. Retorne com controle.',
 FALSE),

('Remada Curvada com Barra',    'back',      'Exercício composto para espessura das costas.',
 '1. Incline o tronco a 45°. 2. Puxe a barra até o abdômen. 3. Contraia as escápulas. 4. Retorne lentamente.',
 FALSE),

('Remada Unilateral com Halter','back',      'Trabalha cada lado das costas individualmente.',
 '1. Apoie joelho e mão no banco. 2. Puxe o halter até o quadril. 3. Contraia as costas. 4. Desça com controle.',
 FALSE),

('Puxada no Cabo (Pulley)',     'back',      'Versão em cabo da puxada, permite maior amplitude.',
 '1. Sente-se na máquina. 2. Agarre o cabo. 3. Puxe até o queixo. 4. Retorne com controle.',
 FALSE),

('Levantamento Terra',          'back',      'Exercício composto rei das costas e posterior.',
 '1. Pé na largura do quadril. 2. Segure a barra próxima às pernas. 3. Levante empurrando o chão. 4. Desça com controle.',
 FALSE),

('Barra Fixa',                  'back',      'Calistenia avançada para costas e bíceps.',
 '1. Pendurar na barra. 2. Puxar o corpo até o queixo passar a barra. 3. Descer completamente.',
 FALSE),

('Serrote com Halter',          'back',      'Foca nos músculos do meio das costas.',
 '1. Incline o tronco. 2. Puxe o halter lateralmente. 3. Eleve até a altura do quadril. 4. Retorne.',
 FALSE),

-- ─── OMBROS ────────────────────────────────────────────────
('Desenvolvimento com Barra',   'shoulders', 'Exercício principal para ombros.',
 '1. Posição de pé ou sentado. 2. Barra na altura dos ombros. 3. Empurre acima da cabeça. 4. Retorne à posição inicial.',
 FALSE),

('Elevação Lateral',            'shoulders', 'Isola o deltoide médio.',
 '1. Em pé, halteres ao lado. 2. Eleve os braços lateralmente até a altura dos ombros. 3. Desça lentamente.',
 FALSE),

('Elevação Frontal',            'shoulders', 'Trabalha o deltoide anterior.',
 '1. Em pé, halteres à frente das coxas. 2. Eleve um braço de cada vez à frente. 3. Retorne com controle.',
 FALSE),

('Crucifixo Invertido',         'shoulders', 'Ativa o deltoide posterior.',
 '1. Incline o tronco à frente. 2. Eleve os braços lateralmente. 3. Sinta a contração na parte traseira do ombro.',
 FALSE),

('Arnold Press',                'shoulders', 'Desenvolvimento rotacional que ativa todos os feixes do deltoide.',
 '1. Inicie com palmas voltadas para você. 2. Suba girando os pulsos. 3. No topo, palmas para fora. 4. Retorne.',
 FALSE),

-- ─── BÍCEPS ────────────────────────────────────────────────
('Rosca Direta com Barra',      'biceps',    'Exercício clássico para bíceps.',
 '1. Em pé, segure a barra com pegada supinada. 2. Flexione o cotovelo até a barra tocar o ombro. 3. Retorne.',
 FALSE),

('Rosca Alternada com Halteres','biceps',    'Permite maior amplitude e equilíbrio muscular.',
 '1. Em pé, halteres ao lado. 2. Flexione alternadamente. 3. Gire o pulso no topo. 4. Retorne com controle.',
 FALSE),

('Rosca Martelo',               'biceps',    'Trabalha bíceps e braquial.',
 '1. Segure halteres com pegada neutra. 2. Flexione sem girar o pulso. 3. Mantenha os cotovelos fixos.',
 FALSE),

('Rosca Concentrada',           'biceps',    'Isolamento máximo do bíceps.',
 '1. Sentado, apoie o cotovelo na coxa. 2. Flexione o braço completamente. 3. Contraia no topo.',
 FALSE),

-- ─── TRÍCEPS ────────────────────────────────────────────────
('Tríceps Pulley',              'triceps',   'Exercício de isolamento com cabo.',
 '1. Agarre a corda no cabo alto. 2. Cotovelos fixos ao lado do corpo. 3. Estenda os braços para baixo. 4. Retorne.',
 FALSE),

('Mergulho em Paralelas',       'triceps',   'Exercício composto para tríceps e peitoral inferior.',
 '1. Apoie nas paralelas. 2. Desça até os cotovelos formarem 90°. 3. Empurre de volta. 4. Mantenha o tronco reto.',
 FALSE),

('Tríceps Testa',               'triceps',   'Isola a cabeça longa do tríceps.',
 '1. Deite no banco. 2. Segure a barra acima da testa. 3. Flexione os cotovelos. 4. Estenda sem mover os braços.',
 FALSE),

('Tríceps Coice',               'triceps',   'Isolamento do tríceps em posição inclinada.',
 '1. Incline o tronco. 2. Cotovelo paralelo ao tronco. 3. Estenda o braço para trás. 4. Retorne.',
 FALSE),

-- ─── ANTEBRAÇO ────────────────────────────────────────────────
('Rosca de Punho',              'forearms',  'Fortalece flexores do antebraço.',
 '1. Sentado, punhos sobre os joelhos. 2. Segure halteres ou barra. 3. Flexione e estenda os punhos.',
 FALSE),

('Rosca de Punho Reversa',      'forearms',  'Fortalece extensores do antebraço.',
 '1. Punhos sobre os joelhos, palmas para baixo. 2. Estenda e flexione os punhos. 3. Use carga leve.',
 FALSE),

-- ─── ABDÔMEN ────────────────────────────────────────────────
('Abdominal Crunch',            'abs',       'Exercício básico para reto abdominal.',
 '1. Deite, joelhos flexionados. 2. Mãos atrás da cabeça. 3. Eleve o tronco contraindo o abdômen. 4. Desça.',
 FALSE),

('Prancha',                     'abs',       'Isométrico para core completo.',
 '1. Apoie nos antebraços e pontas dos pés. 2. Corpo reto. 3. Contraia abdômen e glúteos. 4. Mantenha.',
 FALSE),

('Abdominal Bicicleta',         'abs',       'Ativa oblíquos e reto abdominal.',
 '1. Deite, mãos na cabeça. 2. Eleve os ombros. 3. Leve o cotovelo ao joelho oposto alternadamente.',
 FALSE),

('Elevação de Pernas',          'abs',       'Foca na porção inferior do abdômen.',
 '1. Deite no banco ou chão. 2. Mãos ao lado do corpo. 3. Eleve as pernas a 90°. 4. Desça lentamente.',
 FALSE),

('Russian Twist',               'abs',       'Trabalha oblíquos com rotação.',
 '1. Sentado com pés suspensos. 2. Incline o tronco. 3. Gire de lado a lado com ou sem peso.',
 FALSE),

('Abdominal no Cabo',           'abs',       'Isola o reto abdominal com resistência progressiva.',
 '1. Segure a corda. 2. Incline o tronco para baixo contraindo o abdômen. 3. Retorne à posição inicial.',
 FALSE),

-- ─── QUADRÍCEPS ────────────────────────────────────────────────
('Agachamento Livre',           'quadriceps','Exercício rei das pernas.',
 '1. Pé na largura do ombro. 2. Barra nas costas. 3. Desça até a coxa paralela ao chão. 4. Suba empurrando o chão.',
 FALSE),

('Leg Press 45°',               'quadriceps','Exercício composto seguro para quadríceps.',
 '1. Posicione os pés na plataforma. 2. Desça até 90°. 3. Empurre sem travar os joelhos.',
 FALSE),

('Cadeira Extensora',           'quadriceps','Isolamento do quadríceps.',
 '1. Ajuste o equipamento. 2. Estenda as pernas completamente. 3. Contraia no topo. 4. Retorne com controle.',
 FALSE),

('Avanço (Lunge)',              'quadriceps','Trabalha quadríceps, glúteos e equilíbrio.',
 '1. Em pé, passo à frente. 2. Desça até o joelho traseiro quase tocar o chão. 3. Suba e repita.',
 FALSE),

('Hack Squat',                  'quadriceps','Agachamento na máquina, foca no vasto lateral.',
 '1. Ombros sob as almofadas. 2. Pés na plataforma. 3. Desça profundamente. 4. Empurre de volta.',
 FALSE),

-- ─── POSTERIOR DE COXA ────────────────────────────────────────────────
('Mesa Flexora',                'hamstrings','Isolamento da posterior de coxa.',
 '1. Deite na máquina. 2. Ajuste o rolo sobre os tornozelos. 3. Flexione os joelhos. 4. Retorne lentamente.',
 FALSE),

('Stiff (Levantamento Terra Romeno)','hamstrings','Exercício principal para posterior de coxa.',
 '1. Em pé, barra na frente. 2. Incline o tronco mantendo costas retas. 3. Desça sentindo o alongamento. 4. Suba.',
 FALSE),

('Cadeira Flexora',             'hamstrings','Versão sentada do isolamento de posterior.',
 '1. Ajuste a máquina. 2. Sente-se com joelhos na borda. 3. Flexione os joelhos. 4. Retorne com controle.',
 FALSE),

('Good Morning',                'hamstrings','Trabalha posterior, lombar e glúteos.',
 '1. Barra nas costas. 2. Incline o tronco para frente. 3. Mantenha costas retas. 4. Retorne à posição.',
 FALSE),

-- ─── GLÚTEOS ────────────────────────────────────────────────
('Hip Thrust',                  'glutes',    'Exercício principal para glúteos.',
 '1. Apoie os ombros no banco. 2. Barra no quadril. 3. Eleve o quadril até ficar paralelo ao chão. 4. Contraia e desça.',
 FALSE),

('Glúteo no Cabo',              'glutes',    'Isolamento do glúteo máximo.',
 '1. Encaixe o tornozelo no cabo. 2. Empurre o pé para trás e acima. 3. Contraia no topo.',
 FALSE),

('Abdução de Quadril',          'glutes',    'Trabalha glúteo médio e mínimo.',
 '1. Deite de lado. 2. Eleve a perna superior lateralmente. 3. Contraia no topo. 4. Desça com controle.',
 FALSE),

('Agachamento Sumô',            'glutes',    'Agachamento com foco em glúteos e adutores.',
 '1. Pés bem abertos, dedos para fora. 2. Desça mantendo joelhos alinhados. 3. Empurre de volta.',
 FALSE),

-- ─── PANTURRILHA ────────────────────────────────────────────────
('Panturrilha em Pé',           'calves',    'Exercício clássico para gastrocnêmio.',
 '1. Em pé no degrau. 2. Suba na ponta dos pés. 3. Contraia no topo. 4. Desça abaixo do nível do degrau.',
 FALSE),

('Panturrilha Sentado',         'calves',    'Foca no sóleo (músculo profundo da panturrilha).',
 '1. Sentado na máquina. 2. Joelhos a 90°. 3. Suba na ponta dos pés. 4. Desça com controle.',
 FALSE),

-- ─── CARDIO ────────────────────────────────────────────────
('Corrida na Esteira',          'cardio',    'Cardio clássico para resistência e queima calórica.',
 '1. Ajuste a velocidade gradualmente. 2. Mantenha postura ereta. 3. Braços em 90°. 4. Respire ritmicamente.',
 FALSE),

('Bike Ergométrica',            'cardio',    'Cardio de baixo impacto para articulações.',
 '1. Ajuste o banco. 2. Pedalar com resistência moderada. 3. Manter 60-80 RPM. 4. Postura ereta.',
 FALSE),

('Elíptico',                    'cardio',    'Cardio completo de baixo impacto.',
 '1. Suba no aparelho. 2. Segure as alças. 3. Mova braços e pernas em sincronia. 4. Ajuste a resistência.',
 FALSE),

('Pular Corda',                 'cardio',    'Cardio de alta intensidade e coordenação motora.',
 '1. Segure a corda pelos cabos. 2. Gire os pulsos. 3. Pule no ritmo da corda. 4. Comece devagar.',
 FALSE),

('Burpee',                      'cardio',    'Exercício funcional de alta intensidade.',
 '1. Agache e apoie as mãos. 2. Salte para a posição de prancha. 3. Faça uma flexão. 4. Volte e salte.',
 FALSE),

('Remo Ergométrico',            'cardio',    'Cardio completo que trabalha corpo inteiro.',
 '1. Ajuste os pés. 2. Segure o cabo. 3. Empurre com as pernas. 4. Recline o tronco e puxe o cabo até o abdômen.',
 FALSE),

-- ─── CORPO INTEIRO ────────────────────────────────────────────────
('Kettlebell Swing',            'full_body', 'Exercício funcional para corpo todo.',
 '1. Pés afastados. 2. Segure o kettlebell. 3. Empurre o quadril para trás. 4. Arremesse para frente com explosão.',
 FALSE),

('Clean and Press',             'full_body', 'Levantamento olímpico para força e potência.',
 '1. Barra no chão. 2. Puxe explosivamente. 3. Reposicione a barra nos ombros. 4. Pressione acima da cabeça.',
 FALSE),

('Thruster',                    'full_body', 'Combinação de agachamento frontal com desenvolvimento.',
 '1. Barra nos ombros. 2. Agache profundamente. 3. Ao subir, empurre a barra acima da cabeça.',
 FALSE),

('Farmer Walk',                 'full_body', 'Exercício de força funcional para grip e core.',
 '1. Segure pesos pesados em cada mão. 2. Caminhe mantendo postura ereta. 3. Passos curtos e controlados.',
 FALSE)

ON CONFLICT DO NOTHING;
