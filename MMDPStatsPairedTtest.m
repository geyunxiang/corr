%PAIRED T-TEST
rootpath = '/home/geyx/NAS/geyunxiang/changgeng_SCI/' % root
preprocesses = {'FunImgRWS', 'FunImgRWSD', 'FunImgRWSDC', 'FunImgRWSDCF', 'FunImgRWSDglobalC', 'FunImgRWSDglobalCF'};
personNames = dir([rootpath preprocesses{1}]);
fprintf(1, 'num of person = %d\n', length(personNames));
result = zeros(length(personNames)-2, length(preprocesses)*2-2); % stores t stat and probability
for i = 1:length(preprocesses)-1
	for j = 3:length(personNames)
		% fprintf(1, 'processing person %s on %s\n', personNames(j).name, preprocesses{i});
		personName = personNames(j).name;
		net1 = load([rootpath preprocesses{i} '/' personName '/attrcsvs/inter-region-WholeCor.mat']);
		net1 = net1.WholeCor;
		net1Inter = tril(net1, -1);
		net1InterLong = reshape(net1Inter, prod(size(net1)), 1);
		net1InterLong = net1InterLong(net1InterLong ~= 0);
		net2 = load([rootpath preprocesses{i+1} '/' personName '/attrcsvs/inter-region-WholeCor.mat']);
		net2 = net2.WholeCor;
		net2Inter = tril(net2, -1);
		net2InterLong = reshape(net2Inter, prod(size(net2)), 1);
		net2InterLong = net2InterLong(net2InterLong ~= 0);
		[h, p, ci, stats] = ttest(net1InterLong, net2InterLong);
		% fprintf(1, 'p = %f preprocess = %s, personName = %s\n', p, preprocesses{i}, personName);
		% pause;
		result(j-2, 2*(i-1)+1) = p;
		result(j-2, 2*(i-1)+2) = stats.tstat;
	end
end
save('/home/geyx/Documents/changgeng_SCI.mat', 'result');
header = {'FunImgRWSp', 'FunImgRWSt', 'FunImgRWSDp', 'FunImgRWSDt', 'FunImgRWSDCp', 'FunImgRWSDCt', 'FunImgRWSDCFp', 'FunImgRWSDCFt', 'FunImgRWSDglobalCp', 'FunImgRWSDglobalCt'};
xzfn_write_matrix_to_csv('/home/geyx/Documents/changgeng_SCI.csv', header, result);