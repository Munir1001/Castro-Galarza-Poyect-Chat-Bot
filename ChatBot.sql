PGDMP      7                |            ChatBot    16.3    16.3 -    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    24765    ChatBot    DATABASE     ~   CREATE DATABASE "ChatBot" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Ecuador.1252';
    DROP DATABASE "ChatBot";
                postgres    false            �            1259    24896 	   inventory    TABLE     �   CREATE TABLE public.inventory (
    id integer NOT NULL,
    product_id integer,
    quantity integer,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.inventory;
       public         heap    postgres    false            �            1259    24895    inventory_id_seq    SEQUENCE     �   CREATE SEQUENCE public.inventory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.inventory_id_seq;
       public          postgres    false    222            �           0    0    inventory_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.inventory_id_seq OWNED BY public.inventory.id;
          public          postgres    false    221            �            1259    24870    products    TABLE     �   CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(100),
    description text,
    price numeric,
    image_url character varying(255)
);
    DROP TABLE public.products;
       public         heap    postgres    false            �            1259    24869    products_id_seq    SEQUENCE     �   CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.products_id_seq;
       public          postgres    false    218            �           0    0    products_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;
          public          postgres    false    217            �            1259    24879    services    TABLE     �   CREATE TABLE public.services (
    id integer NOT NULL,
    user_id integer,
    product_id integer,
    start_date date,
    end_date date
);
    DROP TABLE public.services;
       public         heap    postgres    false            �            1259    24878    services_id_seq    SEQUENCE     �   CREATE SEQUENCE public.services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.services_id_seq;
       public          postgres    false    220            �           0    0    services_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.services_id_seq OWNED BY public.services.id;
          public          postgres    false    219            �            1259    24859    users    TABLE     �   CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100),
    cedula character varying(20),
    phone character varying(15)
);
    DROP TABLE public.users;
       public         heap    postgres    false            �            1259    24858    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          postgres    false    216            �           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          postgres    false    215            �            1259    24937    ventas    TABLE     �   CREATE TABLE public.ventas (
    id integer NOT NULL,
    cliente character varying(100),
    producto_id integer,
    cantidad integer,
    fecha_hora_venta timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.ventas;
       public         heap    postgres    false            �            1259    24936    ventas_id_seq    SEQUENCE     �   CREATE SEQUENCE public.ventas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.ventas_id_seq;
       public          postgres    false    224            �           0    0    ventas_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.ventas_id_seq OWNED BY public.ventas.id;
          public          postgres    false    223            1           2604    24899    inventory id    DEFAULT     l   ALTER TABLE ONLY public.inventory ALTER COLUMN id SET DEFAULT nextval('public.inventory_id_seq'::regclass);
 ;   ALTER TABLE public.inventory ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    221    222    222            /           2604    24873    products id    DEFAULT     j   ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);
 :   ALTER TABLE public.products ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    217    218    218            0           2604    24882    services id    DEFAULT     j   ALTER TABLE ONLY public.services ALTER COLUMN id SET DEFAULT nextval('public.services_id_seq'::regclass);
 :   ALTER TABLE public.services ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    220    219    220            .           2604    24862    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    215    216    216            3           2604    24940 	   ventas id    DEFAULT     f   ALTER TABLE ONLY public.ventas ALTER COLUMN id SET DEFAULT nextval('public.ventas_id_seq'::regclass);
 8   ALTER TABLE public.ventas ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    223    224    224            �          0    24896 	   inventory 
   TABLE DATA           K   COPY public.inventory (id, product_id, quantity, last_updated) FROM stdin;
    public          postgres    false    222   �0       �          0    24870    products 
   TABLE DATA           K   COPY public.products (id, name, description, price, image_url) FROM stdin;
    public          postgres    false    218   @1       �          0    24879    services 
   TABLE DATA           Q   COPY public.services (id, user_id, product_id, start_date, end_date) FROM stdin;
    public          postgres    false    220   3       �          0    24859    users 
   TABLE DATA           8   COPY public.users (id, name, cedula, phone) FROM stdin;
    public          postgres    false    216   _3       �          0    24937    ventas 
   TABLE DATA           V   COPY public.ventas (id, cliente, producto_id, cantidad, fecha_hora_venta) FROM stdin;
    public          postgres    false    224   �3       �           0    0    inventory_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.inventory_id_seq', 5, true);
          public          postgres    false    221            �           0    0    products_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.products_id_seq', 5, true);
          public          postgres    false    217            �           0    0    services_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.services_id_seq', 5, true);
          public          postgres    false    219            �           0    0    users_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.users_id_seq', 5, true);
          public          postgres    false    215            �           0    0    ventas_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.ventas_id_seq', 10, true);
          public          postgres    false    223            @           2606    24902    inventory inventory_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.inventory DROP CONSTRAINT inventory_pkey;
       public            postgres    false    222            <           2606    24877    products products_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.products DROP CONSTRAINT products_pkey;
       public            postgres    false    218            >           2606    24884    services services_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.services DROP CONSTRAINT services_pkey;
       public            postgres    false    220            6           2606    24866    users users_cedula_key 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_cedula_key UNIQUE (cedula);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_cedula_key;
       public            postgres    false    216            8           2606    24868    users users_phone_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_phone_key;
       public            postgres    false    216            :           2606    24864    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    216            B           2606    24943    ventas ventas_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.ventas DROP CONSTRAINT ventas_pkey;
       public            postgres    false    224            E           2606    24903 #   inventory inventory_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);
 M   ALTER TABLE ONLY public.inventory DROP CONSTRAINT inventory_product_id_fkey;
       public          postgres    false    218    222    4668            C           2606    24890 !   services services_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);
 K   ALTER TABLE ONLY public.services DROP CONSTRAINT services_product_id_fkey;
       public          postgres    false    218    220    4668            D           2606    24885    services services_user_id_fkey    FK CONSTRAINT     }   ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
 H   ALTER TABLE ONLY public.services DROP CONSTRAINT services_user_id_fkey;
       public          postgres    false    216    4666    220            F           2606    24944    ventas ventas_producto_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.products(id);
 H   ALTER TABLE ONLY public.ventas DROP CONSTRAINT ventas_producto_id_fkey;
       public          postgres    false    218    224    4668            �   D   x�}�� !���%�+�g,��D@�<�`�����)?��:a����pجD �+0���Ȭ���v��      �   �  x����n�0���*8��b���4Mk�Ѫ�MJ�dѤ�ǐ�Ml����.a76h������'}��G��Z�*4yNƜ�N*�!�QJ�%Tk�0�rcj}!T��a����1TV��g���Sw9�r����Ԥ�|��D�;��*J��@V�zr�_�W������֔C�߿����$��)��C�M	,/|OsJ.ˌ	.�fO(u����iK'�q��)r=�)B.�clkn{֚��H�2{#�}�`\u*FΎ�	��U}���jr�-\��n6���F���b�������*U]���Ӑ�8]�[;��X�����q�}=.���"~��M��^�un�����;V���� �rxA��(�ȫ,`�ќ"A�j�a��Q�[=��6L=�9F0�2���F^�P��c�q�z���j|�_>����l��H��7      �   I   x�E���0߰K*L5�t�9ZK�#>'�tXMwSv�0Ns���=�*�[�d~Ϫ��D�>��s�|�\�      �   �   x�=�;
�@ �z�s�o�[�E@���`��fe%�7����bN�l��i8���X�y��6���Q��1��w֠�3��c��ՐU�FΏ��K�D�W��*t�_�Ne{	i�
�"��q�r���Mfhȉ�(�u��9�2�      �   �   x��ϻ�@E�x_n���k�J � RfH�:h�%�����'.���6�ޯ��Y�0!���,6�{�
��8ľLw�5XbV$)�~�|OI��&%�� Ò�o)�XZ<*U��t�����s���� >�H]l     